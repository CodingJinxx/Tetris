#include <raylib.h>

// Screen dimensions
#define SCREEN_WIDTH 800
#define SCREEN_HEIGHT 600

int main(void) {
    // Initialize window
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Raylib Game Template");
    SetTargetFPS(60);

    // Game initialization
    Vector2 ballPosition = { (float)SCREEN_WIDTH/2, (float)SCREEN_HEIGHT/2 };
    Vector2 ballSpeed = { 5.0f, 4.0f };
    float ballRadius = 20.0f;

    // Main game loop
    while (!WindowShouldClose()) {
        // Update
        ballPosition.x += ballSpeed.x;
        ballPosition.y += ballSpeed.y;

        // Collision with walls
        if (ballPosition.x >= SCREEN_WIDTH - ballRadius || ballPosition.x <= ballRadius) {
            ballSpeed.x *= -1.0f;
        }
        if (ballPosition.y >= SCREEN_HEIGHT - ballRadius || ballPosition.y <= ballRadius) {
            ballSpeed.y *= -1.0f;
        }

        // Draw
        BeginDrawing();
            ClearBackground(RAYWHITE);
            
            // Draw title
            DrawText("Raylib Game Template", 10, 10, 30, DARKGRAY);
            DrawText("Edit main.c to create your game!", 10, 50, 20, GRAY);
            
            // Draw bouncing ball
            DrawCircleV(ballPosition, ballRadius, MAROON);
            
            // Draw FPS
            DrawFPS(SCREEN_WIDTH - 100, 10);
        EndDrawing();
    }

    // Cleanup
    CloseWindow();
    
    return 0;
}
