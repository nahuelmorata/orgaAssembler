%include "int_to_string.asm"
%include "file_handler.asm"

section .data
	temporal dd  "temporal.txt",0
	nueva_linea db 0x20
	len_nueva_linea equ $- nueva_linea
	salto db 0xa ,0xd
	len_salto equ $- salto
	texto_error_parametros db "Se ingresaron mas parametros de los requeridos.",0xA
	len_texto_error_parametros equ $- texto_error_parametros

section .bss
	buffer resb 1048576

	archivo_salida resd 1
	archivo_entrada resd 1

	cantidad_bytes_archivo resd 1
	contador_letras resd 1
	contador_letras_string resd 1
	contador_palabras resd 1
	contador_palabras_string resd 1
	contador_lineas resd 1
	contador_lineas_string resd 1
	contador_parrafos resd 1
	contador_parrafos_string resd 1

	ultimo_caracter resd 1

section .text
	global _start

_start:
	mov DWORD[contador_letras], 0
	mov DWORD[contador_palabras], 0
	mov DWORD[contador_lineas], 0
	mov DWORD[contador_parrafos], 0
	mov DWORD[cantidad_bytes_archivo], 0

leer_parametros:
	pop EAX		;Saco el primer valor de la pila, la cantidad de argumentos
	cmp EAX, 1	;Si la cantidad de argumentos es 1, solo ingresaron el nombre del programa.
	je cero_parametros	;Salto a la rutina que maneja 0 parámetros.
	cmp EAX, 2	;Si tiene 2 argumentos, contiene el nombre del programa y un parámetro extra.
	je un_parametro	;Salto a la rutina que maneja 1 parámetro extra.
	cmp EAX, 3	;Si tiene 3 argumentos, contiene el nombre del programa y los nombres de los dos archivos a manipular.
	je dos_parametros
	mov EAX, 4	;Servicio sys_write
	mov EBX, 1	;Salida por consola
	mov ECX, texto_error_parametros	;Mensaje a mostrar.
	mov EDX, len_texto_error_parametros	;cantidad de bytes del mensaje a imprimir.
	int 0x80	;Llamada al sistema.
	mov EAX, 1	;Servicio sys_exit
	mov EBX, 3	;Terminación arnormal por otras causas.
	int 0x80	;Llamada al sistema.
cero_parametros:
	mov EAX, 8
	mov EBX, temporal
	mov ECX, 0777
	int 0x80
	
	mov DWORD[archivo_entrada], EAX
	mov ECX, buffer
	mov ESI, 0
leer_consola:  
	mov EAX, 3 ;Servicio sys_read.
	mov EBX, 0 ;entrada estandar.
	mov EDX, 1000 ;tamaño caracter.
	int 0x80 ;invocacion al servicio.
	add ECX, EAX
	add DWORD[cantidad_bytes_archivo], EAX
	add ESI, EAX
	cmp BYTE[buffer + esi - 2],2Dh
	jne leer_consola
	mov ECX,buffer

escribir_temporal:
	mov EAX,4 ;Servicio sys_write
	mov EBX,DWORD[archivo_entrada]
	mov EDX,1 ;tamaño del caracter.
	int 0x80 ;invocacion al servicio
	dec ESI
	inc ECX
	cmp ESI,0
	jne escribir_temporal
	mov EBX, 0
	mov ECX, 0
	mov DWORD[ultimo_caracter], 0
	call calcular_metricas
	jmp mostrar_metricas

un_parametro:
	pop EAX		;Obtengo el nombre del programa y lo descarto
	pop EBX		;Almaceno el nombre del archivo de entrada en EBX.

	.abrir_archivo:
		mov EDX, 0777	;Permisos de lectura/escritura
		mov ESI, 1	;Guardo el valor 1 en ESI porque estoy abriendo el archivo de entrada.
		call abrir_archivo	;Llamo al procedimiento abrir_archivo.

		mov EBX, EDI	;En EDI se encuentra el descriptor del archivo de entrada.
		mov ECX, buffer	;Buffer en donde se guardará el contenido del archivo.
		mov EDX, 1048567	;tamaño máximo del buffer
		mov EDI, cantidad_bytes_archivo	 ;guardo un puntero a una variable para guardar la cantidad de bytes leidos.
		call leer_archivo	;Llamo al procedimiento leer_archivo.


		mov ECX, 0	;ECX será usado como contador de corte para el procedimiento calcular_metricas
		
		mov DWORD[ultimo_caracter], 0	;La variable "ultimo_caracter" será usada por el procedimiento calcular_metricas para ver si el último byte leido es un caracter o un separador.
		mov EBX, 0
		call calcular_metricas	;Llamo al procedimiento calcular_metricas.
		jmp mostrar_metricas

dos_parametros:
	
mostrar_metricas:

	mov EAX, DWORD[contador_letras]
	mov EDI, contador_letras_string
	mov ESI, 0
	call int_to_string
	mov EDX, ESI
	mov EAX, 4
	mov EBX, 1
	mov ECX, contador_letras_string
	int 0x80
	call imprimir_nueva_linea

        mov EAX, DWORD[contador_palabras]
        mov EDI, contador_palabras_string
	mov ESI, 0
        call int_to_string
	mov EDX, ESI
        mov EAX, 4
        mov EBX, 1
        mov ECX, contador_palabras_string
        int 0x80
	call imprimir_nueva_linea

        mov EAX, DWORD[contador_lineas]
        mov EDI, contador_lineas_string
	mov ESI, 0
        call int_to_string
	mov EDX, ESI
        mov EAX, 4
        mov EBX, 1
        mov ECX, contador_lineas_string
        int 0x80
	call imprimir_nueva_linea

        mov EAX, DWORD[contador_parrafos]
        mov EDI, contador_parrafos_string
	mov ESI, 0
        call int_to_string
	mov EDX, ESI
        mov EAX, 4
        mov EBX, 1
        mov ECX, contador_parrafos_string
        int 0x80
	call imprimir_nueva_linea

	mov EAX, 4
	mov EBX, 1
	mov ECX, salto
	mov EDX, len_salto
	int 0x80

fin_sin_errores:
	mov EAX, 1
	mov EBX, 0
	int 0x80

;------Procedimiento calcular_metricas------
;Requiere que los siguientes registros estén inicializados
;cantidad_bytes_archivo: debe contener la cantidad de bytes almacenados en el buffer
;buffer: debe contener el texto almacenado en el archivo
;cantidad_letras: debe estar inicializado en 0
;ECX: debe estar inicializado en 0, será usado como contador de caracteres analizados.
;
;Este procedimiento recorre el buffer de a un byte contando la cantidad
;de letras, palabras, lineas y párrafos contenidos en el texto.
calcular_metricas:
	cmp ECX, DWORD[cantidad_bytes_archivo]
	je .final_del_buffer	;si llegué al final del buffer termino el procedimiento.
	mov AL, BYTE[buffer + ECX]	;capturo el siguiente caracter.
	inc ECX         ;paso al siguiente caracter
	cmp AL, 'A'	;comparo el caracter con la letra 'A'
	jge .candidato_a_letra
	cmp AL, ' '	;comparo el caracter con el espacio
	je .separador
	cmp AL, ';'
	je .separador
	cmp AL, '.'
	je .separador
	cmp AL, ','
	je .separador
	cmp AL, '-'
	je .separador
	cmp AL, 0x9
	je .separador
	cmp AL, '/'
	je .separador
	cmp AL, 0Ah	;comparo con el salto de linea
	je .salto_de_linea
	mov DWORD[ultimo_caracter], 0	;lo uso para saber si lo ultimo que lei es un caracter.
	jmp calcular_metricas	;vuelvo a analizar el siguiente caracter.

	.candidato_a_letra:
	 	cmp AL, 'Z'
		jg .puede_ser_minuscula
		inc DWORD[contador_letras]	;Si es menor o igual a 'Z', es una letra.
		mov DWORD[ultimo_caracter], 1
		mov EBX, 1
		jmp calcular_metricas
	.puede_ser_minuscula:
		cmp AL, 'a'
		jl calcular_metricas	;Si es menor a 'a' no es letra.
		cmp AL, 'z'
		jg calcular_metricas	;Si es mayor a 'z' no es letra.
		inc DWORD[contador_letras]	;Si es mayor o igual a 'a' y menor o igual a 'z', es una letra e incremento el contador.
		mov DWORD[ultimo_caracter], 1
		mov EBX, 1
		jmp calcular_metricas
	.separador:
		cmp DWORD[ultimo_caracter], 1
		je .contar_palabra
		jmp calcular_metricas
	.contar_palabra:
		inc DWORD[contador_palabras]
		mov DWORD[ultimo_caracter], 0
		jmp calcular_metricas
	.salto_de_linea:
		inc DWORD[contador_lineas]
		cmp EBX, 0
		je .separador
		inc DWORD[contador_parrafos]
		mov EBX, 0
		jmp .separador
	.final_del_buffer:
		cmp EBX, 1
		jne .terminar
		inc DWORD[contador_parrafos]
		inc DWORD[contador_lineas]
		.terminar:
		ret
imprimir_nueva_linea:
	mov EAX, 4
	mov EBX, 1
	mov ECX, nueva_linea
	mov EDX, len_nueva_linea
	int 0x80
	ret
