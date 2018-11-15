section .data
	temporal db "temporal.txt",0
 
section .bss
	buffer resb 1000000 ;Reserva 1MB 
	
	arch_entrada resd 1

section .text
	global _start; etiqueta global que marca el comienzo del programa

	_start:

	leer_parametros: 
		pop eax ;Saco primer valor de la pila, contiene ARGC.
		cmp eax,1 ;Comparo el valor de eax con 1 para saber si contiene el nombre del programa.
		je cero_parametros ;Si el valor de eax equivale a un 1 salta a cero_parametros.
	cero_parametros:
		mov eax,8 ;Servicio sys_creat
		mov ebx,temporal ;Nombre del archivo
		mov ecx,0777 ;Permiso de lectura, escritura y ejecucion para todos.
		int 80h ;invocacion al servicio.
		
		mov DWORD[arch_entrada],eax
		mov ecx,buffer
		mov esi,0 

	leer_consola:  
		mov eax,3 ;Servicio sys_read.
		mov ebx,0 ;entrada estandar.
		mov edx,1000000 ;tamaño caracter.
		int 80h ;invocacion al servicio.
		add ecx,eax
		add esi,eax
		cmp BYTE[buffer + esi - 2],2Dh
		jne leer_consola
		mov ecx,buffer
		
	escribir_temporal:
		mov eax,4 ;Servicio sys_write
		mov ebx,DWORD[arch_entrada] ;Escribe en archivo		
		mov edx,1 ;tamaño del caracter.
		int 80h ;invocacion al servicio
		dec esi
		cmp esi,0
		inc ecx
		jne escribir_temporal
      salir:
		mov eax,1 ;servicio sys_exit.
		mov ebx,0 ;Terminacion normal sin errores.
		int 80h ;invocacion al servicio.