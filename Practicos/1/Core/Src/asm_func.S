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
	    cbz r0, exit_1   			// Salto a la etiqueta exit si r0 es cero
	    cbz r1, exit_1   			// Salto a la etiqueta exit si r1 es cero
	    movs r3, #0    				// Carga el valor cero en el registro r3
	    mov r2, r1     				// Copia el valor de r1 en r2
	loop_1:
	    subs r2, #1    				// Decrementa el valor de r2 en uno
	    str r3, [r0, r2, LSL #2]  	// Almacena el valor cero en la dirección de memoria calculada a partir de r0 y r2, multiplicada por cuatro debido a LSL #2
	    bne loop_1     				// Salta al loop si r2 no es cero
	exit_1:
	    bx lr          				// Retorno desde la función

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
    	push {r4-r8}				//guarda los registros r4 a r8 en la pila
    loop_2:
    	subs r2, #1 				//decrementamos la longitud
    	ldr r4, [r0, r2, LSL #2] 	//cargamos un valor de 32bits en el r4 y lo desplazamos
    	mul r4, r4, r3 			 	//multiplica r4 por el escalar en r3
    	str r4, [r1, r2, LSL #2] 	//guardamos el resultado de la multiplicacion
    	bne loop_2
    	pop {r4-r8}					//restaura los valores previos de los registros
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
    	push {r4}			   		//guardo r4 en pila
    loop_3:
    	ldrh r3, [r0, r2, LSL #1]   // Cargar valor de medio palabra (16 bits) en r3
    	mul r3, r3, r1              // Multiplicar r3 por el escalar r1
    	strh r3, [r0, r2, LSL #1]   // Sobrescribir el valor original en memoria
		subs r2, #1				    //decremento la longitud en 1
    	bne loop_3
    	pop {r4}
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
	    push {r4}              		// Guardar registros en la pila
	loop_4:
	    ldrh r4, [r0, r2, LSL #1]   // Cargar valor de medio palabra (16 bits) en r4
	    mul r4, r4, r3              // Multiplicar r4 por el escalar r3
	    usat r4, #12                // Saturar el resultado a 12 bits
	    strh r4, [r1, r2, LSL #1]   // Almacenar el resultado en memoria
	    subs r2, #1                 // Decrementar r2
	    bne loop_4                  // Mientras r2 > 0
	    pop {r4}               		// Recuperar registros y retornar
	    bx lr
/*
5) Realice una función que implemente un filtro de ventana móvil de 10 valores sobre un vector de muestras

prototipo: void filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);

*/
.thumb_func
asm_filtroVentana10:
    push {r4, r5, r6}           // Guardar registros en la pila
    mov r6, #10                 // Longitud de la ventana
    mov r5, r2                  // Puntero al vector de entrada
    mov r4, r1                  // Puntero al vector de salida
    ldr r3, [r5], #2            // Cargar primer valor de entrada
    movs r2, #0                 // Inicializar sumatoria a cero
    mov r1, r6                  // Inicializar contador a longitud de ventana
    mov r0, r1                  // Guardar longitud de ventana en r0
loop_5:
    ldrh r1, [r5], #2           // Cargar siguiente valor de entrada
    adds r2, r2, r1             // Sumar valor a la sumatoria
    subs r1, r2, r3             // Restar primer valor de la ventana
    strh r1, [r4], #2           // Guardar resultado en vector de salida
    mov r3, r2                  // Actualizar primer valor de la ventana
    subs r0, r0, #1             // Decrementar contador
    bne loop_5                  // Repetir mientras contador no sea cero
    pop {r4, r5, r6, pc}        // Recuperar registros y retornar
    bx lr
/*
6) Realizar una función que reciba un vector de números signados de 32 bits y los “empaquete” en
otro vector de 16 bits. La función deberá adecuar los valores de entrada a la nueva precisión.

prototipo: void pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);

*/
.thumb_func
asm_pack32to16:
    push {r4, r5}               	// Guardar registros en la pila
    mov r4, r0                      // Puntero al vector de entrada (32 bits)
    mov r5, r1                      // Puntero al vector de salida (16 bits)
    mov r0, r2                      // Longitud del vector
loop_6:
    ldr r1, [r4], #4                // Cargar valor de 32 bits
    movs r1, r1, LSR #16            // Desplazar valor de 32 bits a la derecha para obtener 16 bits
    strh r1, [r5], #2               // Almacenar valor de 16 bits en vector de salida
    subs r0, r0, #1                 // Decrementar contador
    bne loop_6                      // Repetir mientras contador no sea cero
    pop {r4, r5}                    // Recuperar registros y retornar
    bx lr

/*
7) Realizar una función que reciba un vector de números signados de 32 bits y devuelva la posición del máximo del vector.

prototipo: int32_t max (int32_t * vectorIn, uint32_t longitud);
*/

.thumb_func
asm_max32:
    push {r4, r5}               	// Guardar registros en la pila
    mov r4, r0                      // Puntero al vector de entrada
    mov r0, r1                      // Longitud del vector
    ldr r5, [r4], #4                // Cargar primer valor del vector
    mov r1, #0                      // Inicializar posición máxima a cero
    mov r2, r0                      // Inicializar contador a longitud del vector
loop_7:
    ldr r3, [r4], #4                // Cargar siguiente valor del vector
    cmp r3, r5                      // Comparar valor con el máximo actual
    bgt update_max                  // Saltar si el valor es mayor al máximo actual
    subs r2, r2, #1                 // Decrementar contador
    bne loop_7                      // Repetir mientras contador no sea cero
exit_7:
    mov r0, r1                      // Devolver posición del máximo en r0
    pop {r4, r5}                	// Recuperar registros y retornar
    bx lr
update_max:
    mov r5, r3                      // Actualizar máximo con el nuevo valor
    mov r1, r0                      // Actualizar posición máxima con el contador
    b loop_7                        // Continuar con el bucle

/*
8) Realizar una función que reciba un vector de muestras signadas de 32 bits y lo decime descartando una cada N muestras.

prototipo: void downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N);
*/

.thumb_func
asm_downsampleM:
    push {r4, r5}               	// Guardar registros en la pila
    mov r4, r0                      // Puntero al vector de entrada
    mov r5, r1                      // Puntero al vector de salida
    mov r0, r2                      // Longitud del vector
    mov r1, r3                      // Valor de N
    mov r3, #0                      // Inicializar contador
loop_8:
    ldr r2, [r4], #4                // Cargar siguiente muestra del vector de entrada
    cmp r3, r1                      // Comparar contador con N
    beq skip_8                      // Saltar si el contador es igual a N
    str r2, [r5], #4                // Almacenar muestra en el vector de salida
    add r3, r3, #1                  // Incrementar contador
skip_8:
    subs r0, r0, #1                 // Decrementar contador de longitud
    bne loop_8                      // Repetir mientras contador de longitud no sea cero
    pop {r4, r5}                	// Recuperar registros y retornar
    bx lr
/*
9) Realizar una función que reciba un vector de muestras no signadas de 16 bits e invierta su orden.

prototipo: void invertir (uint16_t * vector, uint32_t longitud);
*/
.thumb_func
asm_invertir:
    mov r3, r0                      // Puntero al vector de entrada
    mov r0, r1                      // Longitud del vector
    lsl r1, r1, #1                  // Calcular el número total de bytes
    add r1, r3, r1                  // Calcular la dirección del último elemento
loop_9:
    ldrh r2, [r1]                   // Cargar muestra del último elemento
    strh r2, [r3], #-2              // Almacenar muestra en la dirección actual y retroceder 2 bytes

    subs r0, r0, #1                 // Decrementar contador de longitud
    cmp r0, #0                      // Comparar contador con cero
    bne loop_9                      // Repetir mientras contador no sea cero
    bx lr
/*
10) Realizar una función que recibe un vector de 4096 valores de 16 bits (signados), que corresponden a muestras de audio tomadas a una tasa de muestreo de 44.100 muestras/s. La función
debe introducir un “eco” de la mitad de la amplitud de la muestra original a los 20ms de comenzada la grabación.

Nota: El eco consiste en adicionar a la señal original, la propia señal original dividida por dos y atrasada en 20ms, como muestra la ilustración debajo.
Por qué la cantidad de muestras copiadas iguales es de 882?

Variante: Una vez implementada la función, programar una nueva versión que utilice las instrucciones SIMD para optimizar la ejecución del algoritmo.

SON 882 muestras porque por un lado el sampleo es de 44100 m/s => 0.0227 ms por cada muetra. Por ende en 20ms de retraso, hay 882 muetras (20ms/0.0227ms)

*/

.thumb_func
asm_introducirEco:
    push {r4}                   	// Guardar registros en la pila
    mov r4, r0                      // Puntero al vector de entrada
    mov r0, #4096                   // Longitud del vector (4096 muestras)
    mov r1, #882                    // Cantidad de muestras para el eco (20 ms / 0.0227 ms por muestra = 882 muestras)
    lsl r2, r0, #1                  // Calcular el número total de bytes en el vector (longitud * 2 bytes por muestra)
    add r2, r4, r2                  // Calcular la dirección del último elemento del vector
    sub r3, r2, r1                  // Calcular la dirección del inicio del eco (retrocediendo 882 muestras)
loop_10:
    ldrsh r5, [r3]                  // Cargar muestra del eco
    ldrsh r6, [r4]                  // Cargar muestra original
    add r6, r6, r5, lsr #1          // Sumar muestra original y muestra de eco dividida por dos
    strh r6, [r4], #2               // Almacenar muestra sumada en el vector original y avanzar 2 bytes
    subs r0, r0, #1                 // Decrementar contador de longitud
    cmp r0, #0                      // Comparar contador con cero
    bne loop_10                     // Repetir mientras contador no sea cero
    pop {r4}                    	// Recuperar registros y retornar
    bx lr

//VARIANTE SIMD

asm_introducirEco_SIMD:
    push {r4, r5, r6}           	// Guardar registros en la pila
    mov r4, r0                      // Puntero al vector de entrada
    mov r0, #4096                   // Longitud del vector (4096 muestras)
    mov r1, #882                    // Cantidad de muestras para el eco (20 ms / 0.0227 ms por muestra = 882 muestras)
    lsl r2, r0, #1                  // Calcular el número total de bytes en el vector (longitud * 2 bytes por muestra)
    add r2, r4, r2                  // Calcular la dirección del último elemento del vector
    sub r3, r2, r1                  // Calcular la dirección del inicio del eco (retrocediendo 882 muestras)
    vldr.32 d0, [r3]                // Cargar muestra del eco a registros SIMD
    vshr.s16 q0, q0, #1             // Dividir las muestras del eco por dos
loop_10_2:
    vld1.16 d1, [r4]                // Cargar 2 muestras originales a registros SIMD
    vadd.s16 q1, q1, q0             // Sumar las muestras originales y las muestras del eco
    vst1.16 d2, [r4]!               // Almacenar 2 muestras sumadas en el vector original y avanzar 4 bytes
    subs r0, r0, #2                 // Decrementar contador de longitud en 2 (2 muestras por iteración)
    cmp r0, #0                      // Comparar contador con cero
    bne loop_10_2                   // Repetir mientras contador no sea cero
    pop {r4, r5, r6}            	// Recuperar registros y retornar
    bx lr


/*
11) La correlación cruzada (del inglés cross correlation) es una operación usada para estudiar el grado de similitud de dos señales y su fase relativa, aún en presencia de ruido. La correlación de dos
funciones da como resultado una nueva función llamada función de correlación.

Realizar una función que calcule la correlación entre dos vectores. Luego optimice utilizando instrucciones SIMD.

prototipo: void corr (int16_t *vectorX, int16_t * vector Y, int16_t vectorCorr, uint32_t longitud)


*/

.thumb_func
asm_calcularCorrelacion:
    push {r4, r5, r6}           	// Guardar registros en la pila
    mov r4, r0                      // Puntero al primer vector
    mov r5, r1                      // Puntero al segundo vector
    mov r6, r2                      // Longitud de los vectores
    ldr r0, [r4]                    // Cargar el primer valor del primer vector
    ldr r1, [r5]                    // Cargar el primer valor del segundo vector
    mov r2, #0                      // Inicializar el acumulador de la correlación en cero
loop_11:
    mul r3, r0, r1                  // Multiplicar los valores de los vectores
    add r2, r2, r3                  // Acumular el resultado de la multiplicación
    add r4, r4, #4                  // Avanzar al siguiente valor del primer vector (incrementar en 4 bytes)
    add r5, r5, #4                  // Avanzar al siguiente valor del segundo vector (incrementar en 4 bytes)
    ldr r0, [r4]                    // Cargar el siguiente valor del primer vector
    ldr r1, [r5]                    // Cargar el siguiente valor del segundo vector
    subs r6, r6, #1                 // Decrementar el contador de longitud en 1
    cmp r6, #0                      // Comparar el contador con cero
    bne loop_11                     // Repetir mientras el contador no sea cero
    pop {r4, r5, r6}            	// Recuperar registros y retornar
    bx lr

// con simd

.thumb_func
asm_calcularCorrelacion_SIMD:
    push {r4, r5, r6, r7}       	// Guardar registros en la pila
    mov r4, r0                      // Puntero al primer vector
    mov r5, r1                      // Puntero al segundo vector
    mov r6, r2                      // Longitud de los vectores
    mov r7, r6                      // Copiar la longitud para usarla como contador
    vdup.32 q0, r6                  // Cargar la longitud en un registro SIMD
    ldm r4, {d0-d3}                 // Cargar los primeros 8 elementos del primer vector en registros SIMD
    ldm r5, {d4-d7}                 // Cargar los primeros 8 elementos del segundo vector en registros SIMD
    vmul.i32 q1, q0, d0             // Multiplicar los valores de los vectores por la longitud
    vmla.i32 q1, q0, d4             // Acumular el resultado de la multiplicación
loop_11_2:
    add r4, r4, #32                 // Avanzar al siguiente grupo de 8 elementos del primer vector (incrementar en 32 bytes)
    add r5, r5, #32                 // Avanzar al siguiente grupo de 8 elementos del segundo vector (incrementar en 32 bytes)
    subs r7, r7, #8                 // Decrementar el contador de longitud en 8
    cmp r7, #0                      // Comparar el contador con cero
    beq endloop_11                  // Salir del bucle si el contador es cero
    vldm r4, {d0-d3}                // Cargar los siguientes 8 elementos del primer vector en registros SIMD
    vldm r5, {d4-d7}                // Cargar los siguientes 8 elementos del segundo vector en registros SIMD
    vmla.i32 q1, q0, d0             // Multiplicar y acumular los nuevos valores
    b loop_11_2                     // Repetir el bucle
endloop_11:
    vpadd.i32 d0, d2, d1            // Sumar las partes bajas y altas del registro SIMD
    vpadd.i32 d0, d0, d0            // Sumar los resultados parciales
    vmov r2, s0                     // Mover el resultado final a un registro general
    pop {r4, r5, r6, r7}        	// Recuperar registros y retornar
    bx lr
