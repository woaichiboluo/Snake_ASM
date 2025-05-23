#include <Windows.h>
#include <stdio.h>
#include <conio.h>

int main() {
	auto stdbuffer = GetStdHandle(STD_OUTPUT_HANDLE);
	auto buffer = CreateConsoleScreenBuffer(
		GENERIC_READ | GENERIC_WRITE,
		0,
		NULL,
		1,
		NULL
	);
	CONSOLE_SCREEN_BUFFER_INFO  info;
	GetConsoleScreenBufferInfo(buffer, &info);

	SMALL_RECT rect = { 0,0,800,800};
	auto v = SetConsoleWindowInfo(stdbuffer, FALSE, &rect);
	printf("call = %d\n", v);

	printf("Console Screen Buffer Info:\n");
	// dwsize
	printf("Size: %d x %d\n", info.dwSize.X, info.dwSize.Y);
	// dwCursorPosition
	printf("Cursor Position: %d x %d\n", info.dwCursorPosition.X, info.dwCursorPosition.Y);
	// wAttributes
	printf("Attributes: %d\n", info.wAttributes);
	// srWindow
	printf("Window: %d x %d\n", info.srWindow.Right - info.srWindow.Left + 1, info.srWindow.Bottom - info.srWindow.Top + 1);
	// dwMaximumWindowSize
	printf("Max Window Size: %d x %d\n", info.dwMaximumWindowSize.X, info.dwMaximumWindowSize.Y);
	// wPopupAttributes

	GetConsoleScreenBufferInfo(stdbuffer, &info);

	printf("Console Screen Buffer Info:\n");
	// dwsize
	printf("Size: %d x %d\n", info.dwSize.X, info.dwSize.Y);
	// dwCursorPosition
	printf("Cursor Position: %d x %d\n", info.dwCursorPosition.X, info.dwCursorPosition.Y);
	// wAttributes
	printf("Attributes: %d\n", info.wAttributes);
	// srWindow
	printf("Window: %d x %d\n", info.srWindow.Right - info.srWindow.Left + 1, info.srWindow.Bottom - info.srWindow.Top + 1);
	// dwMaximumWindowSize
	printf("Max Window Size: %d x %d\n", info.dwMaximumWindowSize.X, info.dwMaximumWindowSize.Y);
	// wPopupAttributes
	return 0;
}