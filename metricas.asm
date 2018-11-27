;----------------------------------------------------------
;Proyecto n°2 de Organizacion de computadoras 2018.
;Comision n°5: Parra, Nadina Guadalupe. Morata, Nahuel
;----------------------------------------------------------

section .data

	temporal db "temporal.txt",0 ;Reserva memoria para la cadena de caracteres que representa el archivo temporal.

	error_archivo_entrada db "Error al abrir archivo de entrada.",10 ;Reseva memoria para la cadena de caracteres
									;que representa el error al abrir el archivo entrada.
	largo_error_archivo_entrada equ $ - error_archivo_entrada

	error_archivo_salida db "Error al abrir archivo de salida.",10 ;Reseva memoria para la cadena de caracteres						
									;que representa el error al abrir el archivo salida.
	largo_error_archivo_salida equ $ - error_archivo_salida
	
	error_mas_parametros db "Se ingresaron mas parametros.",10 ;Reseva memoria para la cadena de caracteres
 								;que representa el error al ingresar parametros.
	largo_error_mas_parametros equ $ - error_mas_parametros
	
	error_guionh db "Ingreso de parametro invalido",10 ;Reseva memoria para la cadena de caracteres
 							;que representa el error al ingresar parametro invalido.
	largo_error_guionh equ $ - error_guionh

	ayuda db "Ayuda: ",10,"El programa debe ser invocado desde la linea de comando de la siguiente manera:",10
	largo_ayuda equ $ - ayuda 
	
	ayuda2 db "$ metricas [-h] | [ archivo_entrada | archivo_entrada archivo_salida ]",10
	largo_ayuda2 equ $ - ayuda2 

	ayuda3 db "Las opciones separadas por una barra vertical denotan posibles alternativas",10,"a llamadas por linea de comandos, y los parametros entre corchetes denotan",10,"parametros opcionales.",10,10
	largo_ayuda3 equ $ - ayuda3 
	
	ayuda4 db "Si se invoca el programa sin parametros, se debe ingresar por teclado las",10,"cadenas de caracteres, la secuencia de escape para fin de ingreso es ^D (Ctrl+D).",10,"Luego se mostraran por pantalla el resultado de las metricas calculadas.",10,10
	largo_ayuda4 equ $ - ayuda4 
	
	ayuda5 db "Si se invoca elprograma unicamente con el nombre del archivo_entrada,",10,"se mostraran por pantalla el resultado de las metricas calculadas",10,"tomadas del archivo_entrada.",10,10
	largo_ayuda5 equ $ - ayuda5 
	
	ayuda6 db "Si se invoca el programa con el nombre delarchivo_entrada y",10,"el nombre del archivo_salida. Se retornara el resultado de las metricas calculadas",10,"del archivo_entrada en el archivo_salida.",10,0
	largo_ayuda6 equ $ - ayuda6

	espacio db " ",10 ;Reserva memoria para el char espacio en blanco.
	largo_espacio equ $ -espacio

	

section .bss
	buffer resb 100000 				;Reserva 1MB 
	arch_entrada resd 1				;Reserva 32 bits para guardar el descriptor del archivo entrada.
	arch_salida resd 1				;Reserva 32 bits para guardar el descriptor del archivo salida.
	contador_letras resd 1 				;Reserva 32 bits para guardar el contador de letras en entero.
	contador_palabras resd 1 			;Reserva 32 bits para guardar el contador de palabras en entero.
	contador_lineas resd 1 				;Reserva 32 bits para guardar el contador de lineas en entero.
	contador_parrafos resd 1 			;Reserva 32 bits para guardar el contador de parrafos en entero.
	ultimo resd 1 					;Reserva 32 bits para guardar el valor segun el tipo de simbolo
 							;que se leyo. 1 si fue letra, 0 si fue simbolo.
	es_palabra resd 1				;Reserva 32 bits para guardar el valor de 1 si esta leyendo una
 							;palabra o 0 sino. 
	contador_letras_string resd 1 			;Reserva 32 bits para guardar el contador de letras en string.
	contador_palabras_string resd 1 		;Reserva 32 bits para guardar el contador de palabras en string.
	contador_lineas_string resd 1 			;Reserva 32 bits para guardar el contador de lineas en string.
	contador_parrafos_string resd 1			;Reserva 32 bits para guardar el contador de parrafos en string.
	
	
section .text
	global _start					;Etiqueta global que marca el comienzo del programa.

	;Bloque de inicio de programa.
	_start:
		mov dword[contador_letras],0		;Mueve el valor 0 a contador_letras.
		mov dword[contador_palabras],0		;Mueve el valor 0 a contador_palabras.
		mov dword[contador_lineas],0		;Mueve el valor 0 a contador_lineas.
		mov dword[contador_parrafos],0		;Mueve el valor 0 a contador_parrafos.
		mov dword[ultimo],0			;Mueve el valor 0 a ultimo.
		mov dword[es_palabra],1			;Mueve el valor 1 a es_palabra.

	;Rutina que evalua la cantidad de parametros ingresados por consola.
	leer_parametros: 
		pop eax 				;Saco primer valor de la pila, contiene ARGC.
		cmp eax,1 				;Comparo el valor de eax con 1 para saber si solo tiene el
							;nombre del programa.
		je cero_parametros 			;Si el valor de eax equivale a un 1 salta a cero_parametros.
		cmp eax,2 				;Comparo el valor de eax con 2 para saber si contiene el nombre
							;del programa y un parametro.
		je un_parametro 			;Si el valor de eax equivale a 2 salta a un_parametro.
		cmp eax,3 				;Comparo el valor de eax con 3 para saber si contiene el nombre
							;del programa y dos parametros.
		je dos_parametros 			;Si el valor de eax equivale a 3 salta a dos_parametros.
		jg mas_parametros 			;Si el valor de eax es mayor de 3 salta a mas_parametros.
	
	;Rutina que crea un archivo temporal para guardar lo ingresado por consola para luego evaluar sus metricas y
 	;mostrarlas por pantalla.
	cero_parametros:
		mov eax,8 				;Servicio sys_creat.
		mov ebx,temporal 			;Nombre del archivo.
		mov ecx,0777 				;Permiso de lectura, escritura y ejecucion para todos.
		int 80h 				;invocación al servicio.
		
		mov DWORD[arch_entrada],eax		;Mueve el descriptor del archivo a arch_entrada.
		mov ecx,buffer				;Mueve el buffer al registro ecx.
		mov esi,0				;Mueve el valor 0 al registro esi.
		call leer_consola 			;Llamo a leer_consola.
		mov edi,0				;Mueve el valor 0 al registro edi.
		mov esi,0				;Muevo el valor 0 al registro esi.
		xor eax,eax				;Limpio el registro eax.
		call calcular_metricas			;Llamo a calcular_metricas.
		mov ebx,DWORD[arch_entrada]		;Muevo el registro ebx el descriptor de archivo.
		call cerrar_archivo			;Llamo a cerrar_archivo.
		mov ebx,1 				;Muevo el valor 1 al registro ebx.
		push ebx				;Apilo el registro ebx.
		jmp mostrar_metricas			;Salto a mostrar_metricas.

	;Rutina para abrir el archivo de entrada y verifica si ocurrio un error al abrirlo.
	abrir_archivo:
		mov eax,5 				;Servicio sys_open.
		mov ebx,ecx 				;Nombre del archivo.
		mov ecx, 0 				;Modo de acceso al archivo, solo lectura.
		mov edx,0777 				;Permiso de lectura, escritura y ejecucion para todos.
		int 80h 				;Invocación del servicio.
		
		add eax,2				;Sumo 2 al registro eax.
		cmp eax,0 				;Comparo el valor de eax con 0.
		je error_abrir_entrada 			;Si el valor de eax equivale a 0 salto a error_abrir_entrada.
		sub eax,2				;Resto 2 al registro eax.
		ret					;Retorno

	;Rutina para abrir el archivo de salida y verifica si ocurrio un error al abrirlo.
	abrir_archivo_salida:
		mov eax,5 				;Servicio sys_open.
		mov ebx,ecx 				;Nombre del archivo.
		mov ecx, 1 				;Modo de acceso al archivo, solo escritura.
		mov edx,0777 				;Permiso de lectura, escritura y ejecucion para todos.
		int 80h 				;Invocación del servicio
							
		add eax,2				;Sumo 2 al registro eax.
		cmp eax,0 				;Comparo el valor de eax con 0
		je error_abrir_salida 			;Si el valor de eax equivale a 0 salto a error_abrir_salida.
		sub eax,2				;Resto 2 al registro eax.
		ret					;Retorno
	
	;Rutina para cerrar un archivo, asume que el registro ebx contiene el descriptor del archivo a
 	;cerrar.						
	cerrar_archivo:					
		mov eax,6 				;Servicio sys_close
		int 80h 				;Invocacion del servicio.
		ret					;Retorno
	
	;Rutina que evalua si el parametro ingresado es para mostrar ayuda o un archivo de entrada, si no es asi 
	;sale con error de ingreso invalido.					
	un_parametro:					
		pop ebx					;Saco ebx de la pila que contiene el nombre del programa.
		pop ecx 				;Saco ecx de la pila que contiene el primer argumento.
		cmp BYTE[ecx],45 			;Comparo si el primer caracter del argumento es '-'.
		jne un_parametro_archivo 		;Si no es '-' entonces es un archivo. Salto un_paramero_archivo.
		inc ecx 				;Incremento el puntero hacia la siguiente posicion.
		cmp BYTE[ecx],104 			;Comparo si el segundo caracer del argumento es 'h'
		jne error_ingreso_invalido 		;Si no es 'h' salta a error_ingreso_invalido.
		inc ecx 				;Incremento el puntero hacia la siguiente posicion.
		cmp BYTE[ecx],0 			;Comparo si no hay mas caracteres.
		jne error_ingreso_invalido 		;Si hay mas caracteres, salta a error_ingreso_invalido.
		jmp mostrar_ayuda 			;Salta a mostrar_ayuda.
	
	;Rutina que llama a abrir el archivo de entrada, leerlo, calcular sus metricas y mostrarlas 
	;en pantalla.					
	un_parametro_archivo:				
		call abrir_archivo			;Llama a abrir_archivo.
		mov DWORD[arch_entrada],eax		;Mueve el descriptor de archivo a arch_entrada.
		call leer_archivo 			;Llama a leer_archivo.
		mov edi,0				;Mueve el valor 0 al registro edi.
		mov esi,0				;Mueve el valor 0 al registro esi.
		xor eax,eax				;Limpia el registro eax.
		call calcular_metricas			;Llama a calcular_metricas.
		mov ebx,DWORD[arch_entrada]		;Mueve al registro ebx el descriptor de archivo entrada.
		call cerrar_archivo			;Llama a cerrar_archivo.
		mov ebx,1				;Mueve el valor 1 al registro ebx.
		push ebx				;Apila el registro ebx en la pila.
	        jmp mostrar_metricas 			;Salta a mostrar_metricas.

	;Rutina que llama a abrir el archivo de entrada, leerlo, calcular sus metricas y cerrarlo, luego abre el
 	 ;archivo de salido y escribe las metricas calculadas.
	dos_parametros:					
		pop ebx					;Desapila ebx que contiene el nombre del programa. 
		pop ecx					;Desapila ecx que contiene el primer argumento.
		call abrir_archivo			;Llama a abrir_archivo.
		mov DWORD[arch_entrada],eax		;Mueve el descriptor del archivo a arch_entrada.
		call leer_archivo			;Llama a leer_archivo.
		mov edi,0				;Mueve el valor 0 al registro edi.
		mov esi,0				;Mueve el valor 0 al registro esi.
		xor eax,eax				;Limpia el registro eax.
		call calcular_metricas			;Llama a calcular_metricas.
		mov ebx,DWORD[arch_entrada]		;Mueve el descriptor de archivo entrada al registro ebx.
		call cerrar_archivo			;Llama a cerrar_archivo.
		pop ecx					;Desapila ecx que contiene el segundo argumento.
		call abrir_archivo_salida		;Llama a abrir_archivo_salida.
		mov DWORD[arch_salida],eax		;Mueve el descriptor de archivo a arch_salida.
		mov ebx,DWORD[arch_salida]		;Mueve el descriptor de archivo al registro ebx.
		push ebx				;Apila el registro ebx.
		jmp mostrar_metricas			;Salta a mostrar_metricas.
	
	;Rutina que sale del programa con error por ingresar mas parametros de los
 	;permitidos.					
	mas_parametros:					
		mov eax,4 				;Servicio sys_write.	
		mov ebx,1 				;Salida estandar.
		mov ecx,error_mas_parametros 		;Mensaje a mostrar.
		mov edx,largo_error_mas_parametros 	;Largo del mensaje.
		int 80h 				;Invocación al servicio.
		
		mov eax,1 				;Servicio sys_exit.
		mov ebx,3 				;Terminación anormal por otras causas.
		int 80h 				;Invocación al servicio.
	
	;Rutina que sale del programa sin errores.	
	salgo_sin_errores:
		mov eax,1 				;Servicio sys_exit.
		mov ebx,0 				;Terminación normal sin errores.
		int 80h 				;invocacion al servicio.
	
	;Rutina que lee el texto ingresado por consola y lo guarda en el buffer. Termina de leer cuando se lee el fin
 	;de transmisión.
	leer_consola:  
		mov eax,3 				;Servicio sys_read.
		mov ebx,0 				;Entrada estandar.
		mov edx,1000 				;Tamaño de lo que va a leer.
		int 80h 				;Invocación al servicio.
		add ecx,eax				;Suma al registro ecx el registro eax.
		add esi,eax				;Suma al registro esi el registro eax.
		cmp eax,0				;Compara el registro eax con el valor 0.
		jg leer_consola				;Si eax es mayor a 0 entonces salta a leer_consola.
		mov dword[buffer + esi -1],0		;Mueve el valor nulo al anteultimo caracter que leyo.
		mov ecx,buffer				;Mueve el buffer al registro ecx.
	
	;Rutina que escribe lo guardado en el buffer en un archivo temporal.						
	escribir_temporal:				
		mov eax,4 				;Servicio sys_write.
		mov ebx,DWORD[arch_entrada] 		;Escribe en el archivo.		
		mov edx,1 				;Tamaño del caracter.
		int 80h 				;Invocación al servicio
		dec esi					;Decrementa el registro esi.
		inc ecx					;Incrementa el registro ecx. 
		cmp esi,0				;Comparo el registro esi con el valor 0.
		jne escribir_temporal			;Si no es equivalente salta a escribir_temporal.
		ret					;Retorno

	;Rutina que lee el contenido de un archivo y lo guarda en un buffer.
	leer_archivo:					
		mov eax,3 				;Servicio sys_read.
		mov ebx,DWORD[arch_entrada] 		;Entrada desde archivo.
		mov ecx,buffer				;Lugar donde va a guardar lo que lee.
		mov edx,1000000 			;Tamaño de la que va a leer.
		int 80h 				;Invocación al servicio.
		cmp eax,0				;Comparo al registro eax con el valor 0.
		je mostrar_metricas			;Si es equivalente salta a mostrar_metricas.
		ret					;Retorno

	;Rutina que calcula las metricas de lo leido en el buffer. 
	calcular_metricas:											
		mov al,BYTE[buffer+edi]			;Muevo el caracter del buffer al registro al. 
		inc edi					;Incremento el registro edi.
		cmp al,0 				;Comparo el caracter con nulo.
		je fin_archivo				;Si es equivalente a nulo salta a fin_archivo.
		cmp al,10 				;Comparo el caracter con el salto de linea.
		je salto_de_linea 			;Si es equivalente a salto de linea. Salto a salto_de_linea.
		cmp al,09				;Comparo al caracter con el tabulador.
		je caracter_sep				;Si es equivalente a tabulador, salto a separador_letra.
		cmp al,' ' 				;Comparo el caracter con el ' '.
		je caracter_sep	 			;Si es igual al ' ' salto a separador_letra.
		cmp al,'.' 				;Comparo el caracter con el '.'.
		je caracter_sep	 			;Si es igual al '.' salto a separador_letra.
		cmp al,',' 				;Comparo el caracter con el ','.
		je caracter_sep	 			;Si es igual al ',' salto a separador_letra.
		cmp al,';' 				;Comparo el caracter con el ';'.
		je caracter_sep	 			;Si es igual al ';' salto a separador_letra.
		cmp al,':' 				;Comparo el caracter con el ':'.
		je caracter_sep	 			;Si es igual al ':' salto a separador_letra.
		cmp al,'A'				;Comparo el caracter con 'A'.
		jge mayor_A				;Si es mayor/igual al caracter'A' en la tabla ascii salta a
 							;mayor_A.
		cmp al,'!'				;Comparo el caracter con '!'
		jge simbolo				;Si es mayor/igual a '!' en la tabla ascii salta a simbolo.
		jmp calcular_metricas			;Salto a calcular_metricas.
					
	caracter_sep:
		call separador				;Llama a separador
		jmp calcular_metricas			;Salta a calcular_metricas

	mayor_A:
		cmp al,'Z' 				;Comparo el caracter con 'Z'.
		jle es_letra 				;Si es menor/igual a 'Z' en ascii salto a es_letra.
		cmp al,'a' 				;Comparo el caracter con 'a'.
		jge mayor_a 				;Si es mayor/igual a 'a' en ascii salto a mayor_a.
		jmp simbolo 				;Salto a simbolo.

	mayor_a:
		cmp al,'z' 				;Comparo el caracter con 'z'.
		jle es_letra 				;Si es menor/igual a 'z' en ascii salto a es_letra.
		jmp simbolo				;Salto a simbolo.
		

	es_letra:
		inc DWORD[contador_letras] 		;Incremento el valor de contador_letra.
		mov DWORD[ultimo],1 			;Muevo el valor 1 a ultimo, porque lei letra.
		jmp calcular_metricas			;Salto a calcular_metricas.
							
	separador:
		cmp DWORD[ultimo],1 			;Comparo a ultimo con 1, es decir, si el ult caracter fue letra.
		je evaluar_palabra 			;Si fue letra salto a evaluar_palabra.
		mov DWORD[es_palabra],1			;Muevo el valor 1 a es_palabra 	
		ret					;Retorno
							

	evaluar_palabra:
		mov DWORD[ultimo],0 			;Muevo el valor 0 a ultimo, porque lei un separador.
		cmp DWORD[es_palabra],1			;Comparo a es_palabra con el valor 1.
		je contar_palabra			;Si es 1 salta contar_palabra
		mov DWORD[es_palabra],1			;Mueve el valor 1 a es palabra.
		ret					;Retorno

	contar_palabra:
		inc DWORD[contador_palabras] 		;Incremento el valor de contador_palabra.
		mov esi,1				;Muevo el valor 1 a esi, porque conte una palabra.		
		ret					;Retorno
		

	salto_de_linea:
		inc DWORD[contador_lineas] 		;Incremento el valor de contador_linea.
		call separador 				;Llamo a separador.
		call parrafo 				;Llamo a parrafo.
		mov DWORD[ultimo],0 			;Muevo el valor 0 a ultimo, porque lei un salto de linea.
		mov esi,0				;Muevo el valor 0 al registro esi porque empiezo una nueva linea
		jmp calcular_metricas			;Salto a calcular_metricas.

	parrafo:
		cmp esi,1 				;Comparo al registro esi con 1, si leyo al menos una palabra.
		je contar_parrafos 			;Si leyo al menos una palabra en la linea salta a contar_parrafo
		ret					;Retorno

	contar_parrafos:
		inc DWORD[contador_parrafos] 		;Incremento el valor de contador_parrafo
		ret					;Retorno
	simbolo:
		mov DWORD[es_palabra],0			;Muevo el valor 0 a es_palabra ya que leyo un simbolo.
		jmp calcular_metricas			;Salto a calcular_metricas.

	fin_archivo:
		inc DWORD[contador_lineas]		;Incremento el valor de contador_lineas
		call separador				;Llamo a separador.
		cmp esi, 1				;Comparo si leyo al menos una palabra en la linea.
		jne seguir				;Si no es equivalente a 1 salto a seguir.
		inc DWORD[contador_parrafos]		;Incremento el valor de contador_parrafor.
							
	seguir:						
		ret					;Retorno
	
	;Rutina que escribe un espacio en blanco entre los resultados a mostrar.
	escribir_espacio:
		mov eax,4 				;Servicio sys_write.
		mov ecx,espacio 			;Mensaje a mostrar.
		mov edx,largo_espacio 			;Largo del mensaje.
		int 80h 				;Invocación al servicio.
		ret					;Retorno
	
	;Rutina que convierte un número entero a string.						
	int_to_string:					
		xor ebx,ebx				;Limpia el registro ebx.
	.push_chars:					
		xor EDX, EDX				;Limpia el registro edx.
		mov ECX, 10				;Mueve el valor 10 al registro ecx.
		div ECX					;Divide 
		add EDX, 0x30				;Suma el valor 0 al registro edx.
		push EDX				;Apila el registro edx.
		inc ebx					;Incrementa el registro ebx.
		test EAX, EAX				;Compara logicamente el registro eax.
		jnz .push_chars				;Salta a .push_chars si el registro eax no es 0
	.pop_chars:					
		pop EAX					;Desapila el registro eax.
		inc esi					;Incrementa el registro esi.
		stosb					;Guarda en la direccion almacenada en el registro edi un byte
 							;del registro de al.
		dec ebx					;Descrementa el registro ebx.
		cmp ebx, 0				;Compara el registro ebx con el valor 0.
		jg .pop_chars				;Si el registro ebx es mayor a 0 salta a .pop_chars.
		mov EAX, 0x0a				;Mueve el caracter de salto de linea al registro eax.
		stosb					;Guarda en la direccion almacenada en el registro edi un byte
 							;del registro de al.
		ret					;Retorno
	
	;Rutina que muestra las metricas en pantalla o en el archivo de salida, segun como se haya seteado ebx en la
 	;instrucción anterior.						
	mostrar_metricas:				
		mov eax, DWORD[contador_letras]		;Muevo el valor de contador_letras al registro eax.
		mov edi, contador_letras_string		;Muevo contador_letras_string al registro edi.
		mov esi,0				;Muevo el valor 0 al registro esi.
		call int_to_string			;Llamo a int_to_string
		pop ebx					;Desapilo el registro ebx.
		mov eax,4 				;Servicio sys_write.
		mov ecx,contador_letras_string 		;Mensaje a mostrar.
		mov edx,esi 				;Largo del mensaje.
		int 80h 				;Invocación al servicio.
		
		call escribir_espacio			;Llamo a escribir_espacio
		push ebx				;Apilo el registro ebx.
		mov eax, DWORD[contador_palabras]	;Mueve el valor de contador_palabras al regitro eax.
		mov edi, contador_palabras_string	;Muevo contador_palabras_string al registro edi.
		mov esi,0				;Mueve el valor 0 al registro esi.
		call int_to_string			;Llamo a int_to_string.

		mov eax,4 				;Servicio sys_write.
		pop ebx					;Desapilo al registro ebx.
		mov ecx,contador_palabras_string 	;Mensaje a mostrar.
		mov edx,esi 				;Largo del mensaje.
		int 80h 				;Invocación al servicio.

		call escribir_espacio			;Llamo a escribir_espacio.
		push ebx				;Apilo el registro ebx.
		mov eax, DWORD[contador_lineas]		;Muevo el valor de contador_lineas al registro eax.
		mov edi, contador_lineas_string		;Muevo el contador_lineas_string al registro edi.
		mov esi,0				;Muevo el valor 0 al registro esi.
		call int_to_string			;Llamo a int_to_string.
	
		mov eax,4 				;Servicio sys_write.
		pop ebx					;Desapilo el registro ebx.
		mov ecx,contador_lineas_string 		;Mensaje a mostrar.
		mov edx,esi 				;Largo del mensaje.
		int 80h 				;Invocación al servicio.

		call escribir_espacio			;Llamo a escribir_espacio
		push ebx				;Apilo el registro ebx.
		mov eax, DWORD[contador_parrafos]	;Muevo el valor de contador_parrafos al registro eax.
		mov edi, contador_parrafos_string	;Muevo el contador_parrafos_string al registro edi.
		mov esi,0				;Muevo el valor 0 al registro esi.
		call int_to_string			;Llamo a int_to_string

		mov eax,4 				;Servicio sys_write.
		pop ebx					;Desapilo el registro ebx.
		mov ecx,contador_parrafos_string 	;Mensaje a mostrar.
		mov edx,esi 				;Largo del mensaje.
		int 80h 				;Invocación al servicio.

		call escribir_espacio			;Llamo a escribir_espacio

		cmp ebx,[arch_salida]			;Comparo el registro ebx con el descriptor de archivo.
		je cerrar_salir				;Si es equivalente salto a cerrar_salir.

		jmp salgo_sin_errores			;Salto a salgo_sin_errores.
	
	;Rutina que llama a cerrar el archivo y salta a salir sin errores.
	cerrar_salir:
		call cerrar_archivo			;Llamo a cerrar_archivo.
		jmp salgo_sin_errores			;Salto a salgo_sin_errores.
	
	;Rutina que sale del programa mostrando el error de un ingreso invalido.					
	error_ingreso_invalido:				
		mov eax,4 				;Servicio sys_write.
		mov ebx,1 				;Salida estandar.
		mov ecx,error_guionh 			;Texto a mostrar.
		mov edx,largo_error_guionh 		;Tamaño del texto.
		int 80h					;Invocación al servicio.
		mov eax,1 				;Servicio sys_exit.
		mov ebx,3 				;Terminación anormal por otras causas.
		int 80h 				;Invocación al servicio.

	;Rutina que sale del programa mostrando el error al abrir un archivo de entrada.
	error_abrir_entrada:
		mov eax,4 				;Servicio sys_write.
		mov ebx,1 				;Salida estandar
		mov ecx,error_archivo_entrada 		;Texto a mostrar.
		mov edx,largo_error_archivo_entrada 	;Tamaño del texto.
		int 80h					;Invocación al servicio.
		mov eax,1 				;Servicio sys_exit.
		mov ebx,1 				;Terminación anormal por error en el archivo de entrada.
		int 80h 				;Invocación al servicio.

	;Rutina que sale del programa mostrando el error al abrir un archivo de salida.
	error_abrir_salida:
		mov eax,4 				;Servicio sys_write.
		mov ebx,1 				;Salida estandar.
		mov ecx,error_archivo_salida 		;Texto a mostrar.
		mov edx,largo_error_archivo_salida 	;Tamaño del texto.
		int 80h					;Invocación al servicio.
		mov eax,1 				;Servicio sys_exit.
		mov ebx,2 				;Terminación anormal por error en el archivo de salida.
		int 80h 				;Invocación al servicio.
	
	;Rutina que muestra ayuda en consola.	
	mostrar_ayuda:
		mov eax,4 				;Servicio sys_write.
		mov ebx,1 				;Salida estandar.
		mov ecx,ayuda 				;Texto a mostrar.
		mov edx,largo_ayuda 			;Tamaño del texto.
		int 80h					;Invocación al servicio.

		mov eax,4 				;Servicio sys_write.
		mov ebx,1 				;Salida estandar.
		mov ecx,ayuda2 				;Texto a mostrar.
		mov edx,largo_ayuda2 			;Tamaño del texto.
		int 80h					;Invocación al servicio.

		mov eax,4 				;Servicio sys_write.
		mov ebx,1 				;Salida estandar.
		mov ecx,ayuda3 				;Texto a mostrar.
		mov edx,largo_ayuda3 			;Tamaño del texto.
		int 80h					;Invocación al servicio.

		mov eax,4 				;Servicio sys_write.
		mov ebx,1 				;Salida estandar.
		mov ecx,ayuda4 				;Texto a mostrar.
		mov edx,largo_ayuda4 			;Tamaño del texto.
		int 80h					;Invocación al servicio.

		mov eax,4 				;Servicio sys_write.
		mov ebx,1 				;Salida estandar.
		mov ecx,ayuda5 				;Texto a mostrar.
		mov edx,largo_ayuda5 			;Tamaño del texto.
		int 80h					;Invocación al servicio.

		mov eax,4 				;Servicio sys_write.
		mov ebx,1 				;Salida estandar.
		mov ecx,ayuda6 				;Texto a mostrar.
		mov edx,largo_ayuda6 			;Tamaño del texto.
		int 80h					;Invocación al servicio.

		jmp salgo_sin_errores 			;Salta a salgo_sin_errores.
