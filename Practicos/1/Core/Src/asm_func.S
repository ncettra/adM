.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}



/*
1) Realizar una función que inicialice un vector con ceros. La función debe tener el siguiente
prototipo: void zeros (uint32_t * vector, uint32_t longitud);

Parametros:
   r0: dirección del vector (vector)
   r1: longitud (longitud)

*/

.thumb_func
    asm_zeros:
		cbz r0, exit //chequeo si r0 es 0 (salto a la etiqueta exit)
		cbz r1, exit //chequeo si r1 es 0 (salto a la etiqueta exit)
		mov r2, #0 //pongo en el valor 0 el registro r2
	loop:
		subs r1, #1 //subs (substaer y la ultima s es por la bandera) decrementa "1"  el valor del registro (recordemos que en r1 esta la longitud)
		str r2, [r0, r1, LSL #2] // str (store) almacena el valor de r2 en la direccion de memoria calculada a partir de r0 y r1 multiplicada por 4 debido a LSL #2 (corri dos bits)
		bne loop //salta al loop si en el acumulador no quedo un cero
	exit:
        bx lr      //retorno

/*
2) Realizar una función que realice el producto de un vector y un escalar (por ejemplo, podría servir para cambiar el nivel de amplitud de una señal).

prototipo: void productoEscalar32 (uint32_t * vectorIn, uint32_t * vectorOut uint32_t longitud, uint32_t escalar);

Parametros:
   	r0: Vector IN (direccion)
   	r1: Vector OUT (direccion)
	r2: longitud
	r3: escalar a multiplicar

*/


.thumb_func
    asm_productoEscalar32:
    	push {r4-r8}	//guarda los registros r4 a r8 en la pila
    _for:
    	subs r2, #1 // decrementamos la longitud
    	ldr r4, [r0, r2, LSL #2] // cargamos un valor de 32bits en el r4 y lo desplazamos
    	mul r4, r4, r3 			 // multiplica r4 por el escalar en r3
    	str r4, [r1, r2, LSL #2] // guardamos el resultado de la multiplicacion
    	bne _for
    	pop {r4-r8}				//restaura los valores previos de los registros
        bx lr
