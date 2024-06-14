#include "AES128.h"
#include <bits/stdc++.h>

using namespace std;

uint8_t key[] = {
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	'a', 'b', 'c', 'd', 'e', 'f'
};

uint8_t message[] = {
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	'a', 'b', 'c', 'd', 'e', 'f'
};

AES128 aes(key);

void showBytes(uint8_t *b, int n) {
	for (int i = 0; i < n; i++) {
		printf("%02x ", b[i]);
	}
	printf("\n");
}

void showBytes(char *b, int n) {
	showBytes((uint8_t *)b, n);
}

int main() {
	char buff[32] = { 0 };
	int dataSize = 16;

	memcpy(buff, message, 16);
	for (int i = 0; i < dataSize; i+=16) {
		aes.encrypt((uint8_t *)buff + i);
	}
	showBytes(buff, 16);
	printf("\n");

	aes.decrypt((uint8_t *)buff);
	showBytes(buff, 16);

	return 0;
}