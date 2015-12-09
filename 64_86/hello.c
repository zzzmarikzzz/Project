#include <stdio.h>

int main (void)
{
	int a = 0;
	int b = 1;
	int c = 2;
	int d = 3;
	int e = 4;
	int f = 5;
	int g = 6;
	int dp = 7;
	int sign = 0x00;
	int invert = 1;
	
	printf("Введите номера разрядов:\nABCDEFGdp\n");
	scanf("%1d%1d%1d%1d%1d%1d%1d%1d", &a, &b, &c, &d, &e, &f, &g, &dp);
	printf("Если индикатор с общим анодом введите 1, иначе 0 \n");
	scanf("%1d", &invert);
	printf("\n\n");
	printf("sym_table:\n\t; Таблица символов 7SEG индикатора ");
	if (invert)
	printf("с общим анодом\n");
	else
	printf("с общим катодом\n");
	printf("\t; A = Q%d, B = Q%d, C = Q%d, D = Q%d,\n", a, b, c, d);
	printf("\t; E = Q%d, F = Q%d, G = Q%d, dp = Q%d,\n\n", e, f, g, dp);
	
	
	sign = (1<<a|1<<b|1<<c|1<<d|1<<e|1<<f|0<<g|0<<dp); //0
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (0<<a|1<<b|1<<c|0<<d|0<<e|0<<f|0<<g|0<<dp); //1
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; 0, 1\n", sign);
	
	sign = (1<<a|1<<b|0<<c|1<<d|1<<e|0<<f|1<<g|0<<dp); //2
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (1<<a|1<<b|1<<c|1<<d|0<<e|0<<f|1<<g|0<<dp); //3
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; 2, 3\n", sign);
	
	sign = (0<<a|1<<b|1<<c|0<<d|0<<e|1<<f|1<<g|0<<dp); //4
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (1<<a|0<<b|1<<c|1<<d|0<<e|1<<f|1<<g|0<<dp); //5
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; 4, 5\n", sign);
	
	sign = (1<<a|0<<b|1<<c|1<<d|1<<e|1<<f|1<<g|0<<dp); //6
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (1<<a|1<<b|1<<c|0<<d|0<<e|0<<f|0<<g|0<<dp); //7
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; 6, 7\n", sign);
	
	sign = (1<<a|1<<b|1<<c|1<<d|1<<e|1<<f|1<<g|0<<dp); //8
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (1<<a|1<<b|1<<c|1<<d|0<<e|1<<f|1<<g|0<<dp); //9
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; 8, 9\n", sign);
	
	sign = (1<<a|1<<b|1<<c|0<<d|1<<e|1<<f|1<<g|0<<dp); //A
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (0<<a|0<<b|1<<c|1<<d|1<<e|1<<f|1<<g|0<<dp); //b
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; A, b\n", sign);
	
	sign = (1<<a|0<<b|0<<c|1<<d|1<<e|1<<f|0<<g|0<<dp); //C
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (0<<a|1<<b|1<<c|1<<d|1<<e|0<<f|1<<g|0<<dp); //d
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; C, d\n", sign);
	
	sign = (1<<a|0<<b|0<<c|1<<d|1<<e|1<<f|1<<g|0<<dp); //E
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (1<<a|0<<b|0<<c|0<<d|1<<e|1<<f|1<<g|0<<dp); //F
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; E, F\n", sign);
	
	sign = (0<<a|0<<b|0<<c|0<<d|0<<e|0<<f|1<<g|0<<dp); //-
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (0<<a|0<<b|0<<c|1<<d|0<<e|0<<f|0<<g|0<<dp); //_
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; -, _\n", sign);
	
	sign = (1<<a|1<<b|0<<c|0<<d|0<<e|1<<f|1<<g|0<<dp); //degree
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (0<<a|0<<b|0<<c|0<<d|0<<e|0<<f|0<<g|0<<dp); //" "
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; degree, \" \"\n", sign);
	
	sign = (0<<a|0<<b|0<<c|1<<d|1<<e|1<<f|1<<g|0<<dp); //t
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (1<<a|0<<b|1<<c|1<<d|1<<e|1<<f|0<<g|0<<dp); //G
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; t, G\n", sign);
	
	sign = (0<<a|1<<b|1<<c|0<<d|1<<e|1<<f|1<<g|0<<dp); //H
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (0<<a|0<<b|1<<c|0<<d|1<<e|1<<f|1<<g|0<<dp); //h
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; H, h\n", sign);
	
	sign = (0<<a|0<<b|0<<c|1<<d|1<<e|1<<f|0<<g|0<<dp); //L
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (0<<a|0<<b|1<<c|0<<d|1<<e|0<<f|1<<g|0<<dp); //n
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; L, n\n", sign);
	
	sign = (0<<a|0<<b|1<<c|1<<d|1<<e|0<<f|1<<g|0<<dp); //o
	if (invert) {sign ^= 0xFF;}
	printf("\t.DB 0x%02X, ", sign);
	
	sign = (1<<a|1<<b|0<<c|0<<d|1<<e|1<<f|1<<g|0<<dp); //P
	if (invert) {sign ^= 0xFF;}
	printf("0x%02X ; o, P\n", sign);
	

	printf("\n\n");
	return 0;
}

