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
	    cbz r0, exit   // Salto a la etiqueta exit si r0 es cero
	    cbz r1, exit   // Salto a la etiqueta exit si r1 es cero
	    movs r3, #0    // Carga el valor cero en el registro r3
	    mov r2, r1     // Copia el valor de r1 en r2
	loop_1:
	    subs r2, #1    // Decrementa el valor de r2 en uno
	    str r3, [r0, r2, LSL #2]  // Almacena el valor cero en la dirección de memoria calculada a partir de r0 y r2, multiplicada por cuatro debido a LSL #2
	    bne loop_1     // Salta al loop si r2 no es cero
	exit:
	    bx lr          // Retorno desde la función

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
    loop_2:
    	subs r2, #1 // decrementamos la longitud
    	ldr r4, [r0, r2, LSL #2] // cargamos un valor de 32bits en el r4 y lo desplazamos
    	mul r4, r4, r3 			 // multiplica r4 por el escalar en r3
    	str r4, [r1, r2, LSL #2] // guardamos el resultado de la multiplicacion
    	bne loop_2
    	pop {r4-r8}				//restaura los valores previos de los registros
        bx lr
/*
3) Adapte la función del ejercicio 2 para realizar operaciones sobre vectores de 16 bits

prototipo: void productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);

Parametros:
   	r0: Vector IN (direccion)
   	r1: Vector OUT (direccion)
	r2: longitud
	r3: escalar a multiplicar

*/
//NOTA EL H INDICA EL THUMB de 16bits
.thumb_func
    asm_productoEscalar16:
    	push {r4}			   //guardo r4 en pila
    loop_3:
    	ldrh r3, [r0, r2, LSL #1]  // Cargar valor de medio palabra (16 bits) en r3
    	mul r3, r3, r1             // Multiplicar r3 por el escalar r1
    	strh r3, [r0, r2, LSL #1]  // Sobrescribir el valor original en memoria
		subs r2, #1				   //decremento la longitud en 1
    	bne loop_3
    	pop {r4}	//restauramos todo como antess
    	bx lr
/*
4) Adapte la función del ejercicio 3 para saturar el resultado del producto a 12 bits:

prototipo: void productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);

Parametros:
   	r0: Vector IN (direccion)
   	r1: Vector OUT (direccion)
	r2: longitud
	r3: escalar a multiplicar

*/
.thumb_func
asm_productoEscalar12:
	    push {r4, r2}              // Guardar registros en la pila
	loop_4:
	    ldrh r4, [r0, r2, LSL #1]  // Cargar valor de medio palabra (16 bits) en r4
	    mul r4, r4, r3             // Multiplicar r4 por el escalar r3
	    usat r4, #12               // Saturar el resultado a 12 bits
	    strh r4, [r1, r2, LSL #1]  // Almacenar el resultado en memoria
	    subs r2, #1                // Decrementar r2
	    bne loop_4                 // Mientras r2 > 0
	    pop {r4, pc}               // Recuperar registros y retornar
	    bx lr
/*
5) Realice una función que implemente un filtro de ventana móvil de 10 valores sobre un vector de
muestras

prototipo: void filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);

*/
.thumb_func
asm_filtroVentana10:
    push {r4, r5, r6, lr}        // Guardar registros en la pila
    mov r6, #10                  // Longitud de la ventana
    mov r5, r2                  // Puntero al vector de entrada
    mov r4, r1                  // Puntero al vector de salida
    ldr r3, [r5], #2            // Cargar primer valor de entrada
    movs r2, #0                 // Inicializar sumatoria a cero
    mov r1, r6                  // Inicializar contador a longitud de ventana
    mov r0, r1                  // Guardar longitud de ventana en r0
loop_5:
    ldrh r1, [r5], #2            // Cargar siguiente valor de entrada
    adds r2, r2, r1             // Sumar valor a la sumatoria
    subs r1, r2, r3             // Restar primer valor de la ventana
    strh r1, [r4], #2            // Guardar resultado en vector de salida
    mov r3, r2                  // Actualizar primer valor de la ventana
    subs r0, r0, #1             // Decrementar contador
    bne loop_5                   // Repetir mientras contador no sea cero
    pop {r4, r5, r6, pc}        // Recuperar registros y retornar
    bx lr
