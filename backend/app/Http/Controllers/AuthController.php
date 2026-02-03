<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Laravel\Socialite\Facades\Socialite;

class AuthController extends Controller
{
    /**
     * Register a new user with email and password.
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Registration successful',
            'user' => $user,
            'token' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    /**
     * Login with email and password.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Invalid credentials'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'user' => $user,
            'token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    /**
     * Handle social login (Google/Apple).
     * 
     * The mobile app sends the OAuth access token obtained from the provider.
     * We verify it and create/update the user, then issue a Sanctum token.
     */
    public function socialLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'provider' => 'required|string|in:google,apple',
            'access_token' => 'required|string',
            // For Apple, we might also receive identity_token and user data
            'identity_token' => 'nullable|string',
            'name' => 'nullable|string',
            'email' => 'nullable|string|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $provider = $request->provider;
        $accessToken = $request->access_token;

        try {
            if ($provider === 'google') {
                $socialUser = Socialite::driver('google')
                    ->stateless()
                    ->userFromToken($accessToken);
            } elseif ($provider === 'apple') {
                // Apple Sign In handling
                // For Apple, we typically verify the identity_token
                $socialUser = $this->getAppleUser($request);
            }

            if (!$socialUser) {
                return response()->json([
                    'message' => 'Unable to verify social token'
                ], 401);
            }

            // Find or create user
            $user = User::where('provider', $provider)
                ->where('provider_id', $socialUser->getId())
                ->first();

            if (!$user) {
                // Check if user exists with same email
                $user = User::where('email', $socialUser->getEmail())->first();

                if ($user) {
                    // Link social account to existing user
                    $user->update([
                        'provider' => $provider,
                        'provider_id' => $socialUser->getId(),
                        'avatar' => $socialUser->getAvatar(),
                    ]);
                } else {
                    // Create new user
                    $user = User::create([
                        'name' => $socialUser->getName() ?? $request->name ?? 'User',
                        'email' => $socialUser->getEmail() ?? $request->email,
                        'provider' => $provider,
                        'provider_id' => $socialUser->getId(),
                        'avatar' => $socialUser->getAvatar(),
                        'email_verified_at' => now(),
                    ]);
                }
            } else {
                // Update avatar if changed
                $user->update([
                    'avatar' => $socialUser->getAvatar(),
                ]);
            }

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'message' => 'Social login successful',
                'user' => $user,
                'token' => $token,
                'token_type' => 'Bearer',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Social authentication failed',
                'error' => $e->getMessage()
            ], 401);
        }
    }

    /**
     * Get Apple user from identity token.
     * 
     * Note: For production, you should verify the identity_token JWT
     * using Apple's public keys.
     */
    private function getAppleUser(Request $request)
    {
        // In production, decode and verify the identity_token JWT
        // For now, we'll use the provided data
        
        if ($request->identity_token) {
            // Decode the identity token (JWT) to get user info
            $tokenParts = explode('.', $request->identity_token);
            if (count($tokenParts) === 3) {
                $payload = json_decode(base64_decode($tokenParts[1]), true);
                
                return new class($payload, $request) {
                    private $payload;
                    private $request;
                    
                    public function __construct($payload, $request) {
                        $this->payload = $payload;
                        $this->request = $request;
                    }
                    
                    public function getId() {
                        return $this->payload['sub'] ?? null;
                    }
                    
                    public function getEmail() {
                        return $this->payload['email'] ?? $this->request->email;
                    }
                    
                    public function getName() {
                        return $this->request->name;
                    }
                    
                    public function getAvatar() {
                        return null;
                    }
                };
            }
        }

        return null;
    }

    /**
     * Logout - revoke current token.
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully'
        ]);
    }

    /**
     * Get authenticated user.
     */
    public function user(Request $request)
    {
        return response()->json([
            'user' => $request->user()
        ]);
    }
}
