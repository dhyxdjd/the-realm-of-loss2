#include <函数.h>
#include <全局变量.h>
#include "SDL3/SDL_events.h"
#include "SDL3/SDL_keycode.h"
#include "SDL3/SDL_video.h"
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
static const int 窗口宽度 = 648;
static const int 窗口高度 = 800;
int main() {
  SDL_Window *窗口;
  bool 关闭 = false;
  SDL_Init(SDL_INIT_VIDEO);

  窗口 = SDL_CreateWindow("失落之域2", 窗口宽度, 窗口高度, SDL_WINDOW_VULKAN);
  if (窗口 == NULL) {
    SDL_LogError(SDL_LOG_CATEGORY_ERROR, "无法创建窗口：%s\n", SDL_GetError());
    return 1;
  }
  while (!关闭) {
    SDL_Event 事件;

    while (SDL_PollEvent(&事件)) {
      if (事件.type == SDL_EVENT_KEY_DOWN) {
        if (事件.key.key == SDLK_ESCAPE) {
            关闭 = true;
        }
      }
    }
    主游戏界面();
  }
  SDL_DestroyWindow(窗口);
  SDL_Quit();
  return 0;
}
