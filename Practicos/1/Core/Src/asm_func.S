.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum
.global asm_zeros
.global asm_productoEscalar32
.global asm_productoEscalar16
.global asm_productoEscalar12
.global asm_filtroVentana10
.global asm_pack32to16
.global asm_max32
.global asm_downsampleM
.global asm_invertir
.global asm_eco
.global asm_calcularCorrelacion

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
    	push {r4}					//guarda r4 en la pila
    loop_2:
    	subs r2, #1 				//decrementamos la longitud
    	ldr r4, [r0, r2, LSL #2] 	//cargamos un valor de 32bits en el r4 y lo desplazamos
    	mul r4, r4, r3 			 	//multiplica r4 por el escalar en r3
    	str r4, [r1, r2, LSL #2] 	//guardamos el resultado de la multiplicacion
    	bne loop_2
    	pop {r4}					//restaura los valores previos de los registros
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
    	ldrh r4, [r0, r2, LSL #1] 	//cargamos un valor de 32bits en el r4 y lo desplazamos
    	mul r4, r4, r3 			 	//multiplica r4 por el escalar en r3
    	strh r4, [r1, r2, LSL #1] 	//guardamos el resultado de la multiplicacion
    	subs r2, #1 				//decrementamos la longitud
    	bne loop_2
    	pop {r4}					//restaura los valores previos de los registros
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
	    push {r4,r5}              	// Guardar registros en la pila
	loop_4:
	    ldrh r4, [r0, r2, LSL #1]   // Cargar valor de medio palabra (16 bits) en r4
	    mul r5, r4, r3              // Multiplicar r4 por el escalar r3 y lo tiro en r5
	    usat r4, #12, r5            // Saturar el resultado a 12 bits
	    strh r4, [r1, r2, LSL #1]   // Almacenar el resultado en memoria
	    subs r2, #1                 // Decrementar r2
	    bne loop_4                  // Mientras r2 > 0
	    pop {r4,r5}               	// Recuperar registros y retornar
	    bx lr
/*
5) Realice una función que implemente un filtro de ventana móvil de 10 valores sobre un vector de muestras
prototipo: void filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);



*/
.thumb_func
asm_filtroVentana10:
push {r4-r10}

	//r0 vector in
	//r1 vector out
	//r2 logintud
	//r10 -> SampleOffset = 5 (ver en programa en C)
	//r9 -> WindowSize = SampleOffset*2 + 1 ---> 11

	mov r3, r2					// Resguardo longitud (r2) para ver cuando estoy fuera del vector
	mov r9, #11 				// cantidad de muestras ventana
	mov r10, #5 				// posicion de la ventana

loop_5_1: 						// Recorremos VectorIN
	subs r3, #1
	beq exit_5					// Si ya lo recorri saltar al exit
	mov r6, #0					// Limpio el acumulador
	add r4, r3, r10				// Posicion del vector + posicion central de la ventana r3+r10
	cmp r4, r9					// Comparo con la cantidad de muestras que tiene la ventana
	mov r7, #0
	itt gt						// Verifico que si la ventana es maás grande que las muestras restantes
	subgt r7, r4, r9
	subgt r7, #1
	mov r8, r9

loop_5_2:						// Recorremos la ventana para sumar y promediar
	subs r4, #1
	beq loop_5_1
	cmp r2, r4					// ignorar operaciones si estamos afura del vector
	bls loop_5_2
	cmp r4, r7
	ittt ls						// Chequeo si llegue al final
	udivls r6, r6, r8			// Si llegue divido para promediar
	strhls r6, [r1, r3, LSL #1]	// Guardo el resultado en vector out
	bls loop_5_1				// Sigue con el siguiente valor

	ldrh r5, [r0, r4, LSL #1]
	add r6, r6, r5				// r6 = r6 + r5 se suma una muetra más
	b loop_5_2

exit_5:
	pop {r4-r10}
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
	r0: Vector IN
	r1:longitud del vector
	retorno: la posicion del valor maximo en int32
*/

.thumb_func
asm_max32:
    push {r4}
    sub r1, #1
    ldr r2, [r0, r1, LSL #2]    // Se guarda el primer valor para comparar
    mov r3, r1                 	// Se guarda el índice
    subs r1, #1
loop_7:
    ldr r4, [r0, r1, LSL #2]    // Se carga siguiente valor para comparar
    cmp r4, r2                 	// Se compara con el valor cargado previo
    bgt greater_than           	// Salta a greater_than si r4 > r2
    subs r1, #1
    bne loop_7                 	// Vuelve al bucle si no se ha recorrido todo el vector
    b end
greater_than:
    mov r2, r4                 	// Si el nuevo valor es mayor, se almacena en r2 para volver a comparar
    mov r3, r1                 	// Se guarda el índice
    subs r1, #1
    bne loop_7                 	// Vuelve al bucle si no se ha recorrido todo el vector
end:
    pop {r4}
    mov r0, r3                 	// Se guarda el valor de retorno
    bx lr                      	// Colocar el resultado en el registro de retorno

/*
8) Realizar una función que reciba un vector de muestras signadas de 32 bits y lo decime descartando una cada N muestras.
prototipo: void downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N);
	r0: VectorIN
	r1: VectorOut
	r2 longitud
	r3: N saltos
*/

.thumb_func
asm_downsampleM:
    push {r4-r6}
    mov r4, #0                   // i = 0
    mov r5, #0                   // j = 0
loop_8:
    ldr r6, [r0, r4, LSL #2]     // Cargar muestra de vectorIn
    str r6, [r1, r5, LSL #2]     // Almacenar muestra en vectorOut
    add r4, r4, r3               // Incrementar i por N
    add r5, r5, #1               // Incrementar j
    cmp r4, r2                   // Comparar i con longitud
    blt loop_8                   // Volver al bucle si i < longitud
    pop {r4-r6}
    bx lr
/*
9) Realizar una función que reciba un vector de muestras no signadas de 16 bits e invierta su orden.
prototipo: void invertir (uint16_t * vector, uint32_t longitud);
	r0: Vector
	r1: longitud
*/

.thumb_func
asm_invertir:
push {r4}
    	mov r2, #0  				// posicion 0, en r1 tengo el otro extremo
    loop_9:
    	subs r1, #1

    	ldrh r3, [r0, r2, LSL #1]  	// !----->     !
    	ldrh r4, [r0, r1, LSL #1]  	// !     <-----!

    	cmp r1, r2 					//verifico que el indice izq sea distinto al derecho

		itte hi 					// uso el if and then con doble condicionante
		strhhi r3, [r0, r1, LSL #1]	// Intercambio valores de los extremos
		strhhi r4, [r0, r2, LSL #1]
		bls exit_9					// Se ejecuta hasta que las posiciones de r2 y r1 se solapen

    	add r2, #1 					// de un lado decresco y de este crezco (es más facil verlo en la funcion en C)
		bne loop_9
    exit_9:
    	pop {r4}
        bx lr

/*
10) Realizar una función que recibe un vector de 4096 valores de 16 bits (signados), que corresponden a muestras de audio tomadas a una tasa de muestreo de 44.100 muestras/s. La función
debe introducir un “eco” de la mitad de la amplitud de la muestra original a los 20ms de comenzada la grabación.
Nota: El eco consiste en adicionar a la señal original, la propia señal original dividida por dos y atrasada en 20ms, como muestra la ilustración debajo.
Por qué la cantidad de muestras copiadas iguales es de 882?
Variante: Una vez implementada la función, programar una nueva versión que utilice las instrucciones SIMD para optimizar la ejecución del algoritmo.


SON 882 muestras porque por un lado el sampleo es de 44100 m/s => 0.0227 ms por cada muetra. Por ende en 20ms de retraso, hay 882 muetras (20ms/0.0227ms)


	r0: VectorIN
	r1: VectorOUT
	aca hardcodie algunas cosas como las muestras, pero podria introducirlas y calcular mas cosas en funcion de los parametros
*/

.thumb_func
asm_eco:
    	push {r4-r6}
    	mov r4, #882  				// Retraso de 20ms (882)
    	mov r2, #4095 				// Cant de muestras (4096)
    loop_10:
    	sub r3, r2, r4  			// (4096 - 882)
    	ldrsh r5, [r0, r2, LSL #1]  // Cargo la muestra
    	ldrsh r6, [r0, r3, LSL #1]  // Cargo la muestra desplazada
    	asr r6, #1					// Hago un desplazamiento hacia la derecha para dividir por dos
    	add r6, r5, r6 				// Sumo la division anterior a la muestra
    	strh r6, [r1, r2, LSL #1]
    	cmp r2, r4  				// Si el desplazamiento de las muestras alcanza a 882, no hay que agregar "eco"
    	sub r2, #1
    	bne loop_10					// si ya no se agrega "eco" copiamos las muestras directamente
    loop_10_2:
    	ldrh r6, [r0, r2, LSL #1]
    	strh r6, [r1, r2, LSL #1]
    	subs r2, #1
    	bne loop_10_2
    	pop {r4-r6}
        bx lr
//VARIANTE SIMD --- > No encontre donde aplicar instrucciones SIMD para mejorar la performance, quizas si hubiese hecho calculos en funcion de los parametros ingresados podria utilizarlos

/*
11) La correlación cruzada (del inglés cross correlation) es una operación usada para estudiar el grado de similitud de dos señales y su fase relativa, aún en presencia de ruido. La correlación de dos
funciones da como resultado una nueva función llamada función de correlación.

Realizar una función que calcule la correlación entre dos vectores. Luego optimice utilizando instrucciones SIMD.

prototipo: void corr (int16_t *vectorX, int16_t * vector Y, int16_t vectorCorr, uint32_t longitud)

   r0 = vectorX
   r1 = vectorY
   r2 = vectorCorr
   r3 = longitud

*/

.thumb_func
asm_calcularCorrelacion: 		//APLICANDO SIMD
	push {r4, r5, r6}      		// Guardar registros en la pila
    mov r3, r0          		// Cargar dirección de inicio de vectorX en r3
    mov r4, r1          		// Cargar dirección de inicio de vectorY en r4
    mov r5, r2       			// Cargar dirección de inicio de vectorCorr en r5
    mov r6, #0                 	// i = 0
loop_11_1:
    ldrh r0, [r3, r6, lsl #1]  	// vectorX[i]
    mov r1, #0                 	// vectorCorr[i] = 0
    mov r2, #0                 	// j = 0
loop_11_2:
    cmp r2, r6                 	// Comparar j con i
    bhs loop_11_3        	// Si j >= i, salir del bucle interno
    ldrh r7, [r4, r2, lsl #1]  	// vectorY[j]
    smull r8, r9, r0, r7       	// r8:r9 = vectorX[i] * vectorY[j]
    adds r1, r1, r8            	// vectorCorr[i] += r8 (parte baja de la multiplicación)
    adds r2, r2, #1            	// Incrementar j
    b loop_11_2               	// Volver al bucle interno
loop_11_3:
    strh r1, [r5, r6, lsl #1]  	// vectorCorr[i] = r1
    adds r6, r6, #1            	// Incrementar i
    cmp r6, r7                 	// Comparar i con longitud
    blt loop_11_1             	// Si i < longitud, volver al bucle externo
    pop {r4, r5, r6}       		// Restaurar registros y salir
    bx lr
