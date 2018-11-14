section .data
	contador_letras dd 0 ;Contador de letras
	contador_palabras dd 0 ;Contador de palabras
	contador_lineas dd 0 ;Contador de lineas
	contador_parrafos dd 0 ;Contador de parrafos
	ultimo dd 0 ;Ultimo es 0 si lo ultimo que lei fue algo diferente a una letra
		    ;y 1 si lo ultimo fue una letra.

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
	largo_ayuda equ $ - ayuda ;$

section .bss
	buffer resb 1000000 ;Reserva 1MB 
	caracter resb 1 ;Reserva 1 byte
	arch_entrada resb 1
	arch_salida resb 1

section .text
	global _start; etiqueta global que marca el comienzo del programa

	_start:

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
		
		mov arch_entrada,eax
		call leer_consola ;Salta a leer_consola 
		call leer_archivo
		call calcular_metricas ;Salta a calcular_metricas
		call mostrar_metricas ;Salta a mostrar_metricas
		jmp salgo_sin_errores ;Salta a salgo_sin_errores

	abrir_archivo_entrada:
		mov eax,5 ;servicio sys_open
		pop eax
		mov ebx,eax ;Nombre del archivo
		mov ecx, 0 ;0 flags (?)
		mov edx,0777 ;Permiso de lectura, escritura y ejecucion para todos.
		int 80h ;invocacion del servicio
		cmp eax,0 ;Comparo el valor de eax con 0
		jb error_abrir_entrada ;Si el valor de eax es menor a 0  salto a error_abrir
		ret

	abrir_archivo_salida:
		mov eax,5 ;servicio sys_open
		pop eax
		mov ebx,[eax] ;Nombre del archivo
		mov ecx, 0 ;0 flags (?)
		mov edx,0777 ;Permiso de lectura, escritura y ejecucion para todos.
		int 80h ;invocacion del servicio
		cmp eax,0 ;Comparo el valor de eax con 0
		jb error_abrir_salida ;Si el valor de eax es menor a 0 salto a error_abrir
		ret

	cerrar_archivo:
		mov eax,6 ;servicio sys_close
		pop eax ;recupero eax de la pila
		mov ebx,eax ;descriptor del archivo
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
		;Si no empieza con guion, asume archivo entrada. Salta a calcular_metricas
		mov eax,ecx
		push eax
		call abrir_archivo_entrada
		call leer_archivo
		call calcular_metricas 
	        call mostrar_metricas ;Salta a mostrar_metricas.
		jmp salgo_sin_errores

	dos_parametros:
		pop ebx
		call primer_parametro
		call segundo_parametro
	
	primer_parametro:
		pop ecx ;Desapilo el primer argumento
		mov eax,ecx ;Asigno el primer argumento a eax
		push eax
		call abrir_archivo_entrada ;
		call leer_archivo
		call calcular_metricas
		push eax
		call cerrar_archivo

	segundo_parametro:
		pop ecx ;Desapilo el segundo argumento_
		mov eax,ecx ;Asigno el segundo argumento a eax
		call abrir_archivo_salida
		call escribir_metricas
		push eax
		call cerrar_archivo
		jmp salgo_sin_errores
	
	
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
		mov ecx,buffer ;Lee caracteres de la consola.
		mov edx,1000000 ;tamaño caracter.
		int 80h ;invocacion al servicio.
		cmp BYTE[ecx],0h
		je escribir_temporal
		jmp leer_consola
		
	escribir_temporal:
		mov eax,4 ;Servicio sys_write
		mov ebx,arch_entrada ;descriptor del archivo
		mov ecx,buffer ;escribe caracteres en el archivo
		mov edx,1000000 ;tamaño del caracter.
		int 80h ;invocacion al servicio

	leer_archivo:
		;Leo el caracter
		mov eax,3 ;Servicio sys_read.
		mov ebx,arch_entrada ;descriptor de archivo.
		mov ecx,buffer ;Lee caracter.
		mov edx,5242880 ;tamaño caracter.
		int 80h ;invocacion al servicio
		push ecx
		ret
	calcular_metricas:	
		;cambio todos los caracter por ecx e incremento para avanzar
		cmp BYTE[ecx],41h ;Comparo el caracter con el numero 41('A' en hexa)
		jge mayor_A ;Salto a mayor_A
		cmp BYTE[ecx],0Ah ;Comparo el caracter con el numero 0A(salto de linea en hexa)
		je salto_de_linea ;Salto a salto_de_linea
		cmp BYTE[ecx],20h ;Comparo el caracter con el numero 20(' ' en hexa)
		jge mayor_espacio ;Salto a mayor_espacio
		cmp BYTE[ecx],03h ;Comparo el caracter con el numero 03( end of file en hexa)
		jmp seguir
		inc ecx
		call calcular_metricas

	mayor_A:
		cmp BYTE[ecx],5Ah ;Comparo el caracter con el numero 5A('Z' en hexa)
		jle es_letra ;Salto a es_letra
		cmp BYTE[ecx],61h ;Comparo el caracter con el numero 61('a' en hexa)
		jge mayor_a ;Salto a mayor_a

	mayor_a:
		cmp BYTE[ecx],7Ah ;Comparo el caracter con el numero 7A('z' en hexa)
		jle es_letra ;Salto a es_letra
		

	es_letra:
		inc DWORD[contador_letras] ;Incremento contador_letra.
		mov DWORD[ultimo],1 ;Muevo el valor 1 a ultimo, porque lei letra

	separador:
		cmp DWORD[ultimo],1 ;Comparo a ultimo con el numero 1
		je contar_palabra ;Salto a contar_palabra
		mov DWORD[ultimo],0 ;Muevo el valor 0 a ultimo, porque lei un separador.
		ret
		

	contar_palabra:
		inc DWORD[contador_palabras] ;Incremento contador_palabra

	salto_de_linea:
		inc DWORD[contador_lineas] ;Incremento contador_linea
		call separador ;Salto a separador
		call parrafo ;Salto a parrafo
		mov DWORD[ultimo],0 ;Muevo el valor 0 a ultimo, porque lei un salto de linea.

	parrafo:
		cmp DWORD[ultimo],1 ;Comparo a ultimo con el numero 1
		je contar_parrafos ;Salto a contar_parrafo
		ret

	contar_parrafos:
		inc DWORD[contador_parrafos] ;Incremento a contador_parrafo

	mayor_espacio:
		cmp BYTE[ecx],40h ;Comparo el caracter con el numero 40('@' en hexa)
		jle separador ;Salta a separador.
		cmp BYTE[ecx],5Bh ;Comparo el caracter con el numero 5B('[' en hexa)
		jge mayor_corchete ;Salto a mayor_corchete

	mayor_corchete:
		cmp BYTE[ecx],60h ;Comparo el caracter con el numero 60h('-' en hexa)
		jle separador ;Salta a separador.
		cmp BYTE[ecx],7Bh ;Comparo el caracter con el numero 7Bh('{' en hexa)
		jge mayor_llave ;Salto a mayor llave

	mayor_llave:
		cmp BYTE[ecx],7Eh ;Comparo el caracter con el numero 7Eh('~' en hexa)
		jle separador ;Salta a sepador.
		
	
	mostrar_metricas:
		mov eax,4 ;Servicio sys_write.
		mov ebx,1 ;salida estandar.
		mov ecx,contad