section .data
	

	temporal db "temporal.txt",0

	error_archivo_entrada db "Error al abrir archivo de entrada.",10 
	largo_error_archivo_entrada equ $ - error_archivo_entrada

	error_archivo_salida db "Error al abrir archivo de salida.",10
	largo_error_archivo_salida equ $ - error_archivo_salida
	
	error_mas_parametros db "Se ingresaron mas parametros.",10
	largo_error_mas_parametros equ $ - error_mas_parametros
	
	error_guionh db "Ingreso de parametro invalido",10
	largo_error_guionh equ $ - error_guionh

	ayuda db "Ayuda.",10
	largo_ayuda equ $ - ayuda 

	espacio db " ",0
	largo_espacio equ $ -espacio

section .bss
	buffer resb 100000 ;Reserva 1MB 
	arch_entrada resb 1
	arch_salida resb 1

	contador_letras resb 16 ;Contador de letras
	contador_palabras resb 16 ;Contador de palabras
	contador_lineas resb 16 ;Contador de lineas
	contador_parrafos resb 16 ;Contador de parrafos
	ultimo resb 16 ;Ultimo es 0 si lo ultimo que lei fue algo diferente a una letra
		    ;y 1 si lo ultimo fue una letra.

	contador_letras_string resb 16 ;Contador de letras
	contador_palabras_string resb 16 ;Contador de palabras
	contador_lineas_string resb 16 ;Contador de lineas
	contador_parrafos_string resb 16 ;Contador de parrafos
	
section .text
	global _start; etiqueta global que marca el comienzo del programa

	_start:
		mov dword[contador_letras],0
		mov dword[contador_palabras],0
		mov dword[contador_lineas],0
		mov dword[contador_parrafos],0
		mov dword[ultimo],0

	leer_parametros: 
		pop eax ;Saco primer valor de la pila, contiene ARGC.
		cmp eax,1 ;Comparo el valor de eax con 1 para saber si contiene el nombre del programa.
		je cero_parametros ;Si el valor de eax equivale a un 1 salta a cero_parametros.
		cmp eax,2 ;Comparo el valor de eax con 2 para saber si contiene el nombre del programa y un parametro.
		je un_parametro ;Si el valor de eax equivale a dos salta a un_parametro.
		cmp eax,3 ;Comparo el valor de eax con 3 para saber si contiene el nombre del programa y dos parametros.
		je dos_parametros ;Si el valor de eax equivale a 3 salta a dos_parametros.
		jg mas_parametros ;Si el valor de eax es mayor de 3 salta a mas_parametros.
	
	cero_parametros:
		mov eax,8 ;Servicio sys_creat
		mov ebx,temporal ;Nombre del archivo
		mov ecx,0777 ;Permiso de lectura, escritura y ejecucion para todos.
		int 80h ;invocacion al servicio.
		
		mov DWORD[arch_entrada],eax
		mov ecx,buffer
		mov esi,0
		mov edi,0
		call leer_consola ;Salta a leer_consola
		mov ecx,0
		mov esi,0
		call calcular_metricas
		call cerrar_archivo
		mov ebx,1 
		jmp mostrar_metricas

	abrir_archivo_entrada:
		mov eax,5 ;servicio sys_open
		mov ebx,ecx ;Nombre del archivo
		mov ecx, 0 ;0 flags
		mov edx,0777 ;Permiso de lectura, escritura y ejecucion para todos.
		int 80h ;invocacion del servicio
		
		add eax,2
		cmp eax,0 ;Comparo el valor de eax con 0
		je error_abrir_entrada ;Si el valor de eax es menor a 0  salto a error_abrir
		sub eax,2
		ret

	abrir_archivo_salida:
		mov eax,5 ;servicio sys_open
		mov ebx,ecx ;Nombre del archivo
		mov ecx, 0 ;0 flags
		mov edx,0777 ;Permiso de lectura, escritura y ejecucion para todos.
		int 80h ;invocacion del servicio

		add eax,2
		cmp eax,0 ;Comparo el valor de eax con 0
		je error_abrir_salida ;Si el valor de eax es menor a 0 salto a error_abrir
		sub eax,2
		ret

	cerrar_archivo:
		mov eax,6 ;servicio sys_close
		int 80h ;invocacion del servicio.
		ret
	 
	un_parametro:
		pop ebx
		pop ecx ;Saco ecx de la pila
		cmp BYTE[ecx],2Dh ;Comparo si el primer caracter del primer argumento es -
		jne un_parametro_archivo ;Salto a un_paramero_archivo
		inc ecx ;Incremento el puntero hacia la siguiente posicion.
		cmp BYTE[ecx],68h ;Comparo si el segundo caracer del primer argumento es h
		jne error_ingreso_invalido ;Salta a error_ingreso_invalido
		inc ecx ;Incremento el puntero hacia la siguiente posicion.
		cmp BYTE[ecx],0h ;Comparo si no hay mas caracteres;
		jne error_ingreso_invalido ;Salta a error_ingreso_invalido
		jmp mostrar_ayuda ;Salta a mostrar_ayuda
		
	un_parametro_archivo:
		;Si no empieza con guion, asume archivo entrada. Salta a calcular_m
		call abrir_archivo_entrada
		mov DWORD[arch_entrada],eax
		mov edi,0
		call leer_archivo 
		mov ecx,0
		mov esi,0
		call calcular_metricas
		mov ebx,DWORD[arch_entrada]
		call cerrar_archivo
		mov ebx,1
	        jmp mostrar_metricas ;Salta a mostrar_metricas.

	dos_parametros:
		pop ebx
		pop ecx
		call abrir_archivo_entrada
		mov DWORD[arch_entrada],eax
		call leer_archivo
		mov edi,0
		mov esi,0
		call calcular_metricas
		mov ebx,DWORD[arch_entrada]
		call cerrar_archivo
		pop ecx
		call abrir_archivo_salida
		mov DWORD[arch_salida],eax
		mov ebx,DWORD[arch_salida]
		jmp mostrar_metricas
	
	mas_parametros:
		mov eax,4 ;Servicio sys_write.
		mov ebx,1 ;salida estandar.
		mov ecx,error_mas_parametros ;mensaje a mostrar.
		mov edx,largo_error_mas_parametros ;largo del mensaje.
		int 80h ;invocacion al servicio.
		
		mov eax,1 ;servicio sys_exit.
		mov ebx,3 ;Terminacion anormal por otras causas.
		int 80h ;invocacion al servicio.
		
	salgo_sin_errores:
		mov eax,1 ;servicio sys_exit.
		mov ebx,0 ;Terminacion normal sin errores.
		int 80h ;invocacion al servicio.
	
	leer_consola:  
		mov eax,3 ;Servicio sys_read.
		mov ebx,0 ;entrada estandar.
		mov edx,1000 ;tamaño caracter.
		int 80h ;invocacion al servicio.
		add ecx,eax
		add edi,eax
		add esi,eax
		cmp BYTE[buffer + esi - 2],2Dh
		jne leer_consola
		mov ecx,buffer
		
	escribir_temporal:
		mov eax,4 ;Servicio sys_write
		mov ebx,DWORD[arch_entrada] ;Escribe en pantalla		
		mov edx,1 ;tamaño del caracter.
		int 80h ;invocacion al servicio
		dec esi
		inc ecx
		cmp esi,0
		jne escribir_temporal
		ret

	leer_archivo:
		mov eax,3 ;Servicio sys_read.
		mov ebx,DWORD[arch_entrada] ;descriptor de archivo.
		mov ecx,buffer
		mov edx,1000000 ;tamaño caracter.
		int 80h ;invocacion al servicio.
		cmp eax,0
		je error_ingreso_invalido
		add edi,eax
		ret

	calcular_metricas:	
		cmp ecx,edi 
		je fin_archivo
		mov al,BYTE[buffer+ecx]
		inc ecx
		
		cmp al,0Ah ;Comparo el caracter con el numero 0A(salto de linea en hexa)
		je salto_de_linea ;Salto a salto_de_linea
		cmp al,20h ;Comparo el caracter con el numero 20(' ' en hexa)
		jge mayor_espacio ;Salto a mayor_espacio
		
		
		jmp calcular_metricas

	mayor_A:
		cmp al,5Ah ;Comparo el caracter con el numero 5A('Z' en hexa)
		jle es_letra ;Salto a es_letra
		cmp al,61h ;Comparo el caracter con el numero 61('a' en hexa)
		jge mayor_a ;Salto a mayor_a
		call separador ;Salto a separador
		jmp calcular_metricas

	mayor_a:
		cmp al,7Ah ;Comparo el caracter con el numero 7A('z' en hexa)
		jle es_letra ;Salto a es_letra
		call separador ;Salto a separador
		jmp calcular_metricas
		

	es_letra:
		inc DWORD[contador_letras] ;Incremento contador_letra.
		mov DWORD[ultimo],1 ;Muevo el valor 1 a ultimo, porque lei letra
		jmp calcular_metricas

	separador:
		cmp DWORD[ultimo],1 ;Comparo a ultimo con el numero 1
		je contar_palabra ;Salto a contar_palabra
		mov DWORD[ultimo],0 ;Muevo el valor 0 a ultimo, porque lei un separador.
		ret
		

	contar_palabra:
		mov esi,1
		mov DWORD[ultimo],0 ;Muevo el valor 0 a ultimo, porque lei un separador.
		inc DWORD[contador_palabras] ;Incremento contador_palabra
		ret

	salto_de_linea:
		inc DWORD[contador_lineas] ;Incremento contador_linea
		call separador ;Salto a separador
		call parrafo ;Salto a parrafo
		mov DWORD[ultimo],0 ;Muevo el valor 0 a ultimo, porque lei un salto de linea.
		mov esi,0
		jmp calcular_metricas
	parrafo:
		cmp esi,1 ;Comparo a ultimo con el numero 1
		je contar_parrafos ;Salto a contar_parrafo
		ret

	contar_parrafos:
		inc DWORD[contador_parrafos] ;Incremento a contador_parrafo
		ret

	mayor_espacio:
		cmp al,41h ;Comparo el caracter con el numero 41('A' en hexa)
		jge mayor_A ;Salto a mayor_A
		call separador ;Salta a separador.
		jmp calcular_metricas

	fin_archivo:
		inc DWORD[contador_lineas]
		cmp esi, 1
		jne seguir
		inc DWORD[contador_parrafos]
		

	seguir:
		ret	
		
	escribir_espacio:
		mov eax,4 ;Servicio sys_write.
		mov ecx,espacio ;mensaje a mostrar.
		mov edx,largo_espacio ;largo del mensaje.
		int 80h ;invocacion al servicio.
		ret
	
	int_to_string:
		xor esi,esi
	.push_chars:
		xor EDX, EDX
		mov ECX, 10
		div ECX
		add EDX, 0x30
		push EDX
		inc esi
		test EAX, EAX
		jnz .push_chars
	.pop_chars:
		pop EAX
		stosb
		dec esi
		cmp esi, 0
		jg .pop_chars
		mov EAX, 0x0a
		stosb
		ret

	mostrar_metricas:
		mov eax, DWORD[contador_letras]
		mov edi, contador_letras_string
		call int_to_string

		mov eax,4 ;Servicio sys_write.
		
		mov ecx,contador_letras_string ;mensaje a mostrar.
		mov edx,16 ;largo del mensaje.
		int 80h ;invocacion al servicio.
		
		call escribir_espacio
	
		mov eax, DWORD[contador_palabras]
		mov edi, contador_palabras_string
		call int_to_string

		mov eax,4 ;Servicio sys_write.
		
		mov ecx,contador_palabras_string ;mensaje a mostrar.
		mov edx,16 ;largo del mensaje.
		int 80h ;invocacion al servicio.

		call escribir_espacio
		
		mov eax, DWORD[contador_lineas]
		mov edi, contador_lineas_string
		call int_to_string
	
		mov eax,4 ;Servicio sys_write.
		
		mov ecx,contador_lineas_string ;mensaje a mostrar.
		mov edx,16 ;largo del mensaje.
		int 80h ;invocacion al servicio.

		call escribir_espacio

		mov eax, DWORD[contador_parrafos]
		mov edi, contador_parrafos_string
		call int_to_string

		mov eax,4 ;Servicio sys_write.
		
		mov ecx,contador_parrafos_string ;mensaje a mostrar.
		mov edx,16 ;largo del mensaje.
		int 80h ;invocacion al servicio.

		call escribir_espacio
		
		jmp salgo_sin_errores

	
	error_ingreso_invalido:
		mov eax,4 ;Servicio sys_write
		mov ebx,1 ;salida estandar
		mov ecx,error_guionh ;texto a mostrar.
		mov edx,largo_error_guionh ;tamaño del texto.
		int 80h;
		mov eax,1 ;servicio sys_exit.
		mov ebx,3 ;Terminacion anormal por otras causas.
		int 80h ;invocacion al servicio.

	error_abrir_entrada:
		mov eax,4 ;Servicio sys_write
		mov ebx,1 ;salida estandar
		mov ecx,error_archivo_entrada ;texto a mostrar.
		mov edx,largo_error_archivo_entrada ;tamaño del texto.
		int 80h;
		mov eax,1 ;servicio sys_exit.
		mov ebx,1 ;Terminacion anormal por error en el archivo de entrada.
		int 80h ;invocacion al servicio.

	error_abrir_salida:
		mov eax,4 ;Servicio sys_write
		mov ebx,1 ;salida estandar
		mov ecx,error_archivo_salida ;texto a mostrar.
		mov edx,largo_error_archivo_salida ;tamaño del texto.
		int 80h;
		mov eax,1 ;servicio sys_exit.
		mov ebx,2 ;Terminacion anormal por error en el archivo de salida.
		int 80h ;invocacion al servicio.
		
	mostrar_ayuda:
		mov eax,4 ;Servicio sys_write
		mov ebx,1 ;salida estandar
		mov ecx,ayuda ;texto a mostrar.
		mov edx,largo_ayuda ;tamaño del texto.
		int 80h;
		jmp salgo_sin_errores ;Salta a salgo_sin_errores
