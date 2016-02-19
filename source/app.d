#!/usr/bin/rdmd -L-lncursesw

import deimos.ncurses.ncurses;
import std.string, std.stdio, std.process, std.conv;
import core.stdc.locale;
import vkapi, cfg;

void init() {
  setlocale(LC_CTYPE,"");
  initscr;
}

void print(string s) {
  s.toStringz.printw;
}

VKapi get_token(ref string[string] stor) {
  char token;
  "Insert your access token here: ".print;
  spawnShell(`xdg-open "http://oauth.vk.com/authorize?client_id=5110243&scope=friends,wall,messages,audio,offline&redirect_uri=blank.html&display=popup&response_type=token" >> /dev/null`);
  getstr(&token);
  auto strtoken = (cast(char*)&token).to!string;
  stor["token"] = strtoken;
  return new VKapi(strtoken);
}

void color() {
  if (has_colors == false) {
    endwin;
    writeln("Your terminal does not support color... Goodbye");
  }
  start_color;
  init_pair(1, COLOR_RED, Colors.black);
  use_default_colors;
}

enum Colors { black, red, green, yellow, blue, magenta, cyan, white }

void main(string[] args) {
  init;
  color;
  noecho;
  cbreak;
  scope(exit)    endwin;
  scope(failure) endwin;

  auto storage = load;
  auto api = "token" in storage ? new VKapi(storage["token"]) : get_token(storage);

  attron(A_BOLD);
  attron(COLOR_PAIR(1));
  api.vkget("messages.getDialogs", ["count": "1", "offset": "0"]).toPrettyString.print;
  attroff(COLOR_PAIR(1));

  refresh;
  getch;
  storage.save;
}
