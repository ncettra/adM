# Repositorio de Arquitectura de Microprocesadores

Aquí en el readme file se encuentran las respuestas a las preguntas orientadoras propinadas por la catedra.

# # Preguntas orientadoras

-- 1. Describa brevemente los diferentes perfiles de familias de microprocesadores/microcontroladores de ARM. Explique alguna de sus diferencias características.

Cortex-A: Esta familia de microprocesadores ARM está diseñada para ofrecer alto rendimiento y se utiliza en dispositivos móviles, tabletas, sistemas multimedia y otros dispositivos con capacidad de procesamiento avanzada. Estos procesadores suelen incluir múltiples núcleos y soportan sistemas operativos complejos, como Android o Linux.

Cortex-R: Esta familia de microprocesadores ARM está diseñada para aplicaciones en tiempo real, como sistemas de control de procesos industriales o sistemas de seguridad de automóviles. Estos procesadores tienen un alto rendimiento y están optimizados para tareas de procesamiento en tiempo real y de baja latencia.

Cortex-M: Esta familia de microcontroladores ARM está diseñada para sistemas embebidos de baja potencia y bajo costo, como sensores, dispositivos de control de acceso y otros sistemas embebidos. Estos microcontroladores tienen una arquitectura simple y están optimizados para un bajo consumo de energía.




# # CORTEX M

-- 1. Describa brevemente las diferencias entre las familias de procesadores Cortex M0, M3 y M4.

Cortex M0: Es una familia de microcontroladores de bajo costo y bajo consumo de energía, diseñada para aplicaciones embebidas de bajo rendimiento. Ofrece una arquitectura simple con un conjunto reducido de instrucciones, lo que la hace adecuada para aplicaciones que no requieren un alto nivel de procesamiento. 

Cortex M3: Es una familia de microcontroladores de alto rendimiento diseñada para aplicaciones en tiempo real y de alto rendimiento. Tiene una arquitectura más compleja que el Cortex M0, con un conjunto más amplio de instrucciones y una unidad de coma flotante. 

Cortex M4: Es una familia de microcontroladores de alto rendimiento diseñada para aplicaciones que requieren procesamiento de señales digitales y análisis de datos. Incluye todas las características del Cortex M3, además de una unidad de procesamiento de señales digitales (DSP) y una unidad de coma flotante de precisión simple y doble. 


-- 2. ¿Por qué se dice que el set de instrucciones Thumb permite mayor densidad de código?

El conjunto de instrucciones Thumb utiliza instrucciones de 16 bits, lo que lo hace más compacto, esto puede reducir significativamente la cantidad de memoria requerida para almacenar un programa.

-- 3. ¿Qué entiende por arquitectura load-store? ¿Qué tipo de instrucciones no posee este tipo de arquitectura?

En una arquitectura load-store, las instrucciones aritméticas y lógicas no pueden acceder directamente a la memoria, sino que operan solo en los datos que están en los registros de la CPU. Esto significa que cualquier operación aritmética o lógica en la memoria debe primero cargar los datos en los registros, realizar la operación y luego almacenar el resultado de vuelta en la memoria.

Algunas de las instrucciones que no se pueden ejecutar directamente en una arquitectura load-store son aquellas que involucran operaciones de lectura o escritura directa en la memoria, como las instrucciones de entrada/salida (I/O), las instrucciones de llamada al sistema y las instrucciones de manipulación de punteros de memoria. Estas instrucciones a menudo requieren el acceso directo a la memoria sin la necesidad de cargar los datos en los registros de la CPU primero.

-- 4. ¿Cómo es el mapa de memoria de la familia?

Tiene un modelo de memoria plano y lineal. El mapa de memoria de Cortex-M es relativamente simple y consiste en un espacio de direcciones de 32 bits, esto implica un direccionamiento de 2^32 posibles posiciones (4GB)

-- 5. ¿Qué ventajas presenta el uso de los “shadowed pointers” del PSP y el MSP?

El uso de shadowed pointers en los registros MSP y PSP brinda beneficios significativos en términos de seguridad, depuración, tolerancia a fallos y eficiencia en el cambio de contexto. Estas características son valiosas en sistemas embebidos y aplicaciones críticas en tiempo real basadas en la arquitectura ARM Cortex-M.

-- 6. Describa los diferentes modos de privilegio y operación del Cortex M, sus relaciones y como se conmuta de uno al otro. Describa un ejemplo en el que se pasa del modo privilegiado a no priviligiado y nuevamente a privilegiado.

La conmutación entre los modos privilegiado y no privilegiado en el Cortex-M se realiza mediante excepciones y eventos del sistema. El procesador guarda y restaura el estado y los registros relevantes durante el cambio de modo para mantener la integridad del sistema y permitir la ejecución de tareas en diferentes niveles de privilegio.

    Paso del modo privilegiado al no privilegiado:
        -El procesador se encuentra en el modo Handler, con acceso completo a los recursos.
        -Ocurre una excepción o interrupción generada por una tarea en modo Thread.
        -El procesador guarda el estado actual y los registros en la pila del modo Handler.
        -El procesador pasa al modo Thread, con un nivel de privilegio más bajo.
        -La excepción o interrupción se maneja en el modo Thread.
        -Una vez que se completa el manejo de la excepción, el procesador restaura el estado guardado y los registros desde la pila del modo Handler.
        -El procesador vuelve al modo Handler con el nivel de privilegio original.

    Paso del modo no privilegiado al privilegiado:
        -El procesador se encuentra en el modo Thread, con acceso restringido a ciertos recursos.
        -Ocurre una excepción o evento del sistema que requiere acceder al modo Handler.
        -El procesador guarda el estado actual y los registros en la pila del modo Thread.
        -El procesador pasa al modo Handler, con un nivel de privilegio más alto.
        -La excepción o evento del sistema se maneja en el modo Handler.
        -Una vez que se completa el manejo de la excepción, el procesador restaura el estado guardado y los registros desde la pila del modo Thread.
        -El procesador vuelve al modo Thread con el nivel de privilegio original.
        
-- 7. ¿Qué se entiende por modelo de registros ortogonal? Dé un ejemplo

Un modelo de registros ortogonal permite que los registros de un procesador sean utilizados de manera independiente y flexible, sin restricciones específicas sobre su uso o propósito. Esto brinda libertad al programador para asignar y utilizar los registros según las necesidades del programa, lo que proporciona eficiencia y flexibilidad en la programación.

    Esto se visualiza en un programa escrito en assembly por ejemplo, para la arquitectura ARM Cortex-M, se puede utilizar el registro R0 para almacenar un argumento de una función, el registro R1 para realizar cálculos intermedios, el registro R2 para almacenar un resultado parcial, y así sucesivamente.

-- 8. ¿Qué ventajas presenta el uso de intrucciones de ejecución condicional (IT)? Dé un ejemplo.

El uso de instrucciones de ejecución condicional, también conocidas como IT (If-Then), ofrece varias ventajas en términos de eficiencia y ahorro de código en la programación en lenguaje Assembly

    ITTE NE
    ANDNE r0,r0,r1
    ADDNE r2,r2,#1
    MOVEQ r2,r3
    
-- 9. Describa brevemente las excepciones más prioritarias (reset, NMI, Hardfault).


    Reset:
        - El reset es la excepción más prioritaria y se produce al iniciar o reiniciar el sistema. Cuando se activa el reset, se borra la memoria y se restablecen los registros del procesador a sus valores iniciales. Es el punto de partida para la ejecución del programa y establece el estado inicial del sistema.
 
 
    NMI:
        - Se utiliza para eventos críticos que requieren una atención inmediata y no pueden ser bloqueados o deshabilitados.
 

    HardFault:
        - Es una excepción que ocurre cuando se produce una falla grave o una condición de error que el sistema no puede manejar. Puede ser causada por divisiones por cero, acceso a memoria no válida o instrucciones ilegales, entre otros.
    
Estas excepciones son consideradas prioritarias debido a su importancia en el funcionamiento del sistema y la necesidad de manejarlas de manera adecuada para garantizar la estabilidad y confiabilidad


-- 10. Describa las funciones principales de la pila. ¿Cómo resuelve la arquitectura el llamado a funciones y su retorno?

Su principal función es administrar la memoria para el almacenamiento temporal de datos y el manejo de llamadas a funciones.

    - Almacenamiento temporal: La pila se utiliza para almacenar datos temporales, como variables locales, registros de activación de funciones y valores de retorno. Cada vez que se llama a una función, los datos locales y los registros de activación se almacenan en la pila para su uso durante la ejecución de la función.

    - Gestión de llamadas a funciones: La pila se utiliza para administrar el flujo de ejecución cuando se realizan llamadas a funciones. Cuando se llama a una función, se almacena en la pila la dirección de retorno, que permite que el programa principal regrese a la ubicación correcta una vez que la función haya terminado su ejecución.

    - Recuperación de contexto: La pila permite que el sistema recupere el contexto original después de la ejecución de una función. Cuando una función finaliza su ejecución, los datos almacenados en la pila, incluyendo la dirección de retorno, se recuperan y se restablece el contexto anterior para continuar con la ejecución del programa principal.
    
FUNCIONES Y RETORNO

    - Antes de llamar a una función, se almacenan en la pila los datos necesarios, como la dirección de retorno y los parámetros de la función. Luego, se cambia el flujo de ejecución hacia la función llamada, comenzando desde la dirección de inicio de la función.

    - Cuando una función finaliza su ejecución, se recupera la dirección de retorno almacenada en la pila. Esto permite que el programa principal continúe la ejecución a partir de la ubicación correcta donde se realizó la llamada a la función. Además, los datos locales y los registros de activación se eliminan de la pila, liberando así la memoria ocupada por la función.

-- 11. Describa la secuencia de reset del microprocesador.

-   Hard Reset: El reset físico se produce cuando se aplica una señal de reinicio a nivel de hardware, como pulsar el botón de reinicio en un dispositivo. Esta señal se propaga a través del sistema y activa el circuito de reset interno del microprocesador.
-   Soft Reset: Todos los registros internos del microprocesador se restablecen a sus valores iniciales. Esto incluye los registros de propósito general, registros de estado, registros de control, etc. La memoria principal, como la RAM y la memoria caché, se borra y se inicializa a un estado conocido. Esto garantiza que no haya datos residuales o basura almacenados en la memoria. Se establecen los modos de operación iniciales del microprocesador, como el modo privilegiado, el modo de interrupción, etc. Se establecen los registros especiales que controlan el comportamiento del microprocesador, como el registro de puntero de pila (SP) y el registro de dirección de programa (PC).

-- 12. ¿Qué entiende por “core peripherals”? ¿Qué diferencia existe entre estos y el resto de los periféricos?

Se refieren a los componentes periféricos esenciales que están integrados directamente en el núcleo del microcontrolador. Estos periféricos se consideran esenciales para el funcionamiento básico del procesador y su interacción con el entorno externo. Los periféricos externos son componentes adicionales que se pueden agregar según las necesidades del sistema. Los core peripherals son cruciales para las funciones básicas del procesador, mientras que los periféricos externos agregan funcionalidades específicas y amplían las capacidades del sistema.

-- 13. ¿Cómo se implementan las prioridades de las interrupciones? Dé un ejemplo

Las interrupciones se clasifican en diferentes niveles de prioridad. Cada interrupción se asigna a un nivel específico, donde un nivel más alto indica una prioridad más alta. Por ejemplo, puede haber niveles de prioridad que van desde 0 (la más alta) hasta n (la más baja), donde n es el número total de niveles de prioridad. Si se produce una interrupción de mayor prioridad mientras se está atendiendo una interrupción de menor prioridad, el controlador de interrupciones suspende temporalmente la rutina en curso y ejecuta la rutina de servicio de la interrupción de mayor prioridad. Una vez finalizada esta rutina, se reanuda la rutina anteriormente en curso.

-- 14. ¿Qué es el CMSIS? ¿Qué función cumple? ¿Quién lo provee? ¿Qué ventajas aporta?
El CMSIS es un estándar proporcionado por ARM que ofrece una capa de abstracción de hardware, bibliotecas y herramientas para facilitar el desarrollo de software embebido en microcontroladores Cortex-M. El uso del CMSIS mejora la portabilidad del software, aumenta la eficiencia y productividad, y garantiza la compatibilidad con herramientas de desarrollo.

-- 17. ¿Qué es el systick? ¿Por qué puede afirmarse que su implementación favorece la portabilidad de los sistemas operativos embebidos?

El SysTick es un temporizador integrado que proporciona una cuenta descendente hacia cero en función de un reloj de referencia y genera interrupciones cuando llega a cero.
Favorece la portabilidad gracias a su disponibilidad universal, su temporización precisa y flexible. Esto permite que los sistemas operativos se adapten fácilmente a diferentes plataformas y aprovechen las capacidades del temporizador para la gestión de eventos y la temporización precisa.

-- 18. ¿Qué funciones cumple la unidad de protección de memoria (MPU)?

Permite establecer políticas de protección y seguridad para la memoria y otros recursos del sistema. La MPU puede dividir la memoria en diferentes regiones y asignar permisos de acceso a cada una de ellas. De esta manera, se pueden prevenir accesos no autorizados a regiones críticas del sistema, proteger los datos del usuario y evitar que se corrompa la memoria. 

-- 19. ¿Cuántas regiones pueden configurarse como máximo? ¿Qué ocurre en caso de haber solapamientos de las regiones? ¿Qué ocurre con las zonas de memoria no cubiertas por las regiones definidas?

En cortex M4 se pueden configurar un máximo de ocho regiones mediante la unidad de protección de memoria, en caso de que se produzcan solapamientos entre las regiones configuradas, la región con el número de región más bajo (es decir, la región definida primero) tendrá prioridad sobre las demás. Esto significa que si hay solapamientos entre las regiones configuradas, se aplicarán los atributos de la región con el número de región más bajo y los atributos de las regiones superpuestas de mayor número de región se ignorarán para esa porción de memoria. Las zonas de memoria no cubiertas (las no portegidas por la MPU) no estarán sujetas a las restricciones de acceso o atributos de protección definidos por las regiones configuradas. Estas zonas de memoria no cubiertas pueden utilizarse para almacenar datos o código sin restricciones de acceso o pueden ser asignadas para otros fines según las necesidades del sistema.

-- 20. ¿Para qué se suele utilizar la excepción PendSV? ¿Cómo se relaciona su uso con el resto de las excepciones? Dé un ejemplo

Se utiliza en sistemas operativos en tiempo real (RTOS) para realizar tareas de planificación y cambios de contexto. Su función principal es permitir la implementación de una operación de cambio de contexto del procesador de forma programada.
Un ejemplo de uso es en un sistema con múltiples tareas o hilos en un RTOS. Cuando una tarea necesita ceder el procesador y permitir que otra tarea se ejecute, puede solicitar el cambio de contexto a través de la excepción PendSV. El kernel del RTOS atenderá la excepción PendSV, realizará el cambio de contexto y la siguiente tarea en la planificación del sistema se ejecutará en el procesador.

-- 21. ¿Para qué se suele utilizar la excepción SVC? Expliquelo dentro de un marco de un sistema operativo embebido.

Cuando un programa necesita realizar una operación que requiere privilegios o que solo puede ser realizada por el kernel del sistema operativo, puede generar una excepción SVC. Esto permite que la ejecución pase al kernel en modo privilegiado para manejar la solicitud (pueden incluir operaciones de gestión de memoria, creación y destrucción de tareas, sincronización, acceso a dispositivos de E/S, etc).


# # ISA

-- 1. ¿Qué son los sufijos y para qué se los utiliza? Dé un ejemplo

Los sufijos se utilizan para especificar condiciones de ejecución y tamaños de datos en las instrucciones

-- 2. ¿Para qué se utiliza el sufijo ‘s’? Dé un ejemplo

Se utiliza para indicar que una instrucción aritmética o lógica debe actualizar las banderas de estado después de su ejecución. Esto es útil para tomar decisiones condicionales basadas en el resultado de la operación.

-- 3. ¿Qué utilidad tiene la implementación de instrucciones de aritmética saturada? Dé un ejemplo con operaciones con datos de 8 bits.

Es útil para evitar desbordamientos en operaciones aritméticas y garantizar resultados válidos dentro de un rango predefinido. Un ejemplo donde se puede aplicar es el control del volumen, suponiendo los 8 bits al sobrepasar el 255, por desbordamiento pasaria a cero, o viceversa (de 0 a 255), en este caso aplicar este tipo de implementacion seria util.

-- 4. Describa brevemente la interfaz entre assembler y C ¿Cómo se reciben los argumentos de las funciones? ¿Cómo se devuelve el resultado? ¿Qué registros deben guardarse en la pila antes de ser modificados?

La interfaz entre ensamblador y C establece cómo se pasan los argumentos, se devuelve el resultado y se gestionan los registros en el contexto de una llamada a una función escrita en C desde código ensamblador. Siguiendo las convenciones establecidas, se garantiza la comunicación y compatibilidad adecuada entre ambos lenguajes. Los registros deben ser guardados ante cada llamada de funcion para preservar el contexto de la tarea anterior, es decir si estoy utilizando los registros y llamo a la funcion "suma", debo guardar los registros en memoria para ejecutar la funcion y posteriormente volver a cargar los registros

-- 5. ¿Qué es una instrucción SIMD? ¿En qué se aplican y que ventajas reporta su uso? Dé un ejemplo.

Las instrucciones SIMD permiten realizar operaciones en paralelo en conjuntos de datos, lo que resulta en un mayor rendimiento, un uso eficiente de los recursos y una optimización del código.
