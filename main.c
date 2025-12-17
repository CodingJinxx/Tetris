#include <raylib.h>
#include <stdio.h>
#include <stdint.h>
#include "font_cache.h"

#define PADDING 20
#define MAX_FONT_SIZE 20
#define CELL_GAP 2
#define CELL_SIZE 40
#define GRID_HEIGHT 40
#define GRID_VERTICAL_OUT_OF_SIGHT 20
#define GRID_WIDTH 10

#define GRID_PIXEL_WIDTH (CELL_SIZE + CELL_GAP) * GRID_WIDTH - CELL_GAP
#define GRID_PIXEL_HEIGHT (CELL_SIZE + CELL_GAP) * (GRID_HEIGHT - GRID_VERTICAL_OUT_OF_SIGHT) - CELL_GAP

#define SIDE_PANEL_MARGIN_LEFT PADDING

#define SCORE_PANEL_WIDTH 200
#define SCORE_PANEL_HEIGHT 100

// TODO: Use preprocessor directives #if to calculate max of side panel elements in width
#define SIDE_PANEL_WIDTH SCORE_PANEL_WIDTH

// Screen dimensions
#define SCREEN_WIDTH PADDING + GRID_PIXEL_WIDTH + SIDE_PANEL_MARGIN_LEFT + SIDE_PANEL_WIDTH + PADDING
#define SCREEN_HEIGHT PADDING + GRID_PIXEL_HEIGHT + PADDING

#define BG_COLOR (Color){71, 71, 71, 255}
#define CELL_BG (Color){120, 120, 120, 255}
#define SCORE_BG (Color){120, 120, 120, 255}

typedef struct {
  unsigned int Score;
} GameState;

typedef struct {
  Font TextFont;
} Resources;

void Update();
void Render(Resources *resources, GameState *game_state);
void LoadResources(Resources *resources);
void DrawBackground();
void DrawGridBackground(int x_origin, int y_origin);
void DrawScorePanelBackground(int x_origin, int y_origin);
void DrawScorePanel(int x_origin, int y_origin, Resources *resources, GameState *game_state);
void DrawNextTetriminoPanel(int x_origin, int y_origin, GameState *game_state);
void DrawLevelPanel(int x_origin, int y_origin, GameState *game_state);

int main(void) {
  // Initialize window
  InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Tetris | Made by Jay");
  SetTargetFPS(240);

  GameState game_state = {0};
  Resources resources = {};

  LoadResources(&resources);

  // Main game loop
  while (!WindowShouldClose()) {
    Update();

    game_state.Score += 999;
    // Draw
    BeginDrawing();
    Render(&resources, &game_state);
    EndDrawing();
  }

  // Cleanup
  CloseWindow();

  return 0;
}

void LoadResources(Resources *resources) {
  resources->TextFont = LoadFontEx("./resources/PressStart2P-Regular.ttf", MAX_FONT_SIZE, 0, 250);
  // Use bilinear filtering for smoother scaling of font texture
  SetTextureFilter(resources->TextFont.texture, TEXTURE_FILTER_POINT);
}

void Render(Resources *resources, GameState *game_state) {
  ClearBackground(BG_COLOR);
  DrawBackground();

  DrawScorePanel(PADDING + GRID_PIXEL_WIDTH + SIDE_PANEL_MARGIN_LEFT, PADDING, resources, game_state);
}

void DrawBackground() {
  DrawGridBackground(PADDING, PADDING);
  DrawScorePanelBackground(PADDING + GRID_PIXEL_WIDTH + SIDE_PANEL_MARGIN_LEFT, PADDING);
}

void DrawGridBackground(int x_origin, int y_origin) {
  for (int i = 0; i < GRID_WIDTH; i++) {
    for (int j = 0; j < GRID_HEIGHT - GRID_VERTICAL_OUT_OF_SIGHT; j++) {
      DrawRectangle(x_origin + i * CELL_SIZE + i * CELL_GAP, y_origin + j * CELL_SIZE + j * CELL_GAP, CELL_SIZE, CELL_SIZE, CELL_BG);
    }
  }
}

void DrawScorePanelBackground(int x_origin, int y_origin) { DrawRectangle(x_origin, y_origin, SCORE_PANEL_WIDTH, SCORE_PANEL_HEIGHT, SCORE_BG); }

void DrawScorePanel(int x_origin, int y_origin, Resources *resources, GameState *game_state) {
  // Ensure panel background
  DrawRectangle(x_origin, y_origin, SCORE_PANEL_WIDTH, SCORE_PANEL_HEIGHT, SCORE_BG);

  // Prepare label and score text
  const char *label = "Score:";
  unsigned int displayScore = game_state->Score;
  if (displayScore > 999999u)
    displayScore = 999999u;
  char scoreBuf[16];
  snprintf(scoreBuf, sizeof(scoreBuf), "%06u", displayScore);

  // inner padding inside the panel
  const int innerPad = 8;
  int maxTextWidth = SCORE_PANEL_WIDTH - innerPad * 2;
  int maxTextHeight = SCORE_PANEL_HEIGHT - innerPad * 2;

  // Find largest font size where both strings fit horizontally and combined vertically
  int bestSize = FindBestFontSize(resources->TextFont, label, scoreBuf, maxTextWidth, maxTextHeight, MAX_FONT_SIZE, 6, 4);

  Vector2 laSz = MeasureTextEx(resources->TextFont, label, (float)bestSize, 0);
  Vector2 lvSz = MeasureTextEx(resources->TextFont, scoreBuf, (float)bestSize, 0);
  int gap = 4;
  float totalH = laSz.y + lvSz.y + gap;
  float startY = y_origin + (SCORE_PANEL_HEIGHT - totalH) / 2.0f;

  float lblX = x_origin + (SCORE_PANEL_WIDTH - laSz.x) / 2.0f;
  float lblY = startY;
  DrawTextEx(resources->TextFont, label, (Vector2){lblX, lblY}, (float)bestSize, 0, BLACK);

  float valX = x_origin + (SCORE_PANEL_WIDTH - lvSz.x) / 2.0f;
  float valY = startY + laSz.y + gap;
  DrawTextEx(resources->TextFont, scoreBuf, (Vector2){valX, valY}, (float)bestSize, 0, BLACK);
}

void Update() {}
