#include <iostream>
#include <string>
#include <cstdlib>

#ifdef _WIN32
#include <windows.h>
#else
#include <sys/ioctl.h>
#endif

std::string getWindowTitle() {
    std::string title;
    if (const char* envTitle = std::getenv("title")) {
        title = envTitle;
    }
    return title;
}

int getConsoleWidth() {
#ifdef _WIN32
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);
    return csbi.srWindow.Right - csbi.srWindow.Left + 1;
#else
    struct winsize size;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &size);
    return size.ws_col;
#endif
}

void printBanner(const std::string& title, int width) {
    std::string bannerLine = std::string(width, '=');

    std::cout << bannerLine << std::endl;

    int titlePadding = (width - 2 - static_cast<int>(title.length())) / 2;
    std::string titleLine = "|" + std::string(titlePadding, ' ') + title + std::string(titlePadding, ' ');
    if (title.length() % 2 != 0)
        titleLine += " ";
    titleLine += "|";
    std::cout << titleLine << std::endl;

    std::cout << bannerLine << std::endl;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Error: Please provide a title as a positional argument." << std::endl;
        return 1;
    }

    std::string title;
    for (int i = 1; i < argc; ++i) {
        title += argv[i];
        if (i < argc - 1)
            title += " ";
    }

    int consoleWidth = getConsoleWidth();

    printBanner(title, consoleWidth);

    return 0;
}
