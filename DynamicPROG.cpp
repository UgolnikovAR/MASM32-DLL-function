#include <iostream>
#include <cstring>
#include <windows.h>

typedef char*(*LibFunction)(char* destynation, char* source, int size);

int main()
{
//инициализация ресурсов
	//char arrsource[100] {"A AB ABC 1 ABCD 12 ABCDE ABCDEF 12 ABCDEFG 1234 ABCDEF 1 ABCDE 123 ABCD [] ABC AB A\0"};
	char arrsource[1000] {0};
//	std::cout <<"\n\""<< arrsource << "\"\n\n";
	int size = 0;
	char destynation[1000] {0};
	char* result = nullptr;

	HINSTANCE hLib;
	LibFunction str_findwords = nullptr;
//загрузка динамической библиотеки
	hLib = LoadLibrary(TEXT("str_findwords.dll"));
//в случае неудачной загрузки,
//вывод сообщения об ошибке и закрытие программы
	if(hLib == NULL)
	{
		std::cout << "Devide to load \"str_findwords.dll\"" << std::endl;
		system("pause");
		return 1;
	}
//вызов функции из подключенной динамической библиотеки
	str_findwords = (LibFunction)GetProcAddress(hLib, "str_findwords");
	if(str_findwords)
	{
		std::cout << "\t\tSTART PROGRAMM..\n\n";

//пользовательсуий ввод строки
		std::cout << "Please, input string:\t";
		std::cin.getline(arrsource, 100);
	//пользовательский ввод параметра размера искомых слов
		std::cout << "Please, input size: ";
		std::cin >> size;
		char* source = arrsource;
		result = str_findwords(destynation, source, size);
//вывод результата
		std::cout << "\nResult:\t\"" << result << "\"\n";
	}
	else
	{
		std::cout << "Function not found" << "\n\n";
	}
	
//вывод сообщения об остановке программы
	std::cout << "\n\t\t    ..DONE\n";
	system("pause");
//выгрузка библиотеки, выход из программы
	FreeLibrary(hLib);
	return 0;
}