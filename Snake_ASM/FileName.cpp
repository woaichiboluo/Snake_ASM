#include <Windows.h>
#include <stdio.h>
#include <conio.h>

int main() {

	while (true) {
		if (_kbhit) {
			auto v = _getch();
			printf("key = %d\n", v);
		}
	}
	// W 119 S 115 A 97 D 100
	// UP 72 DOWN 80 LEFT 75 RIGHT 77
	return 0;
}