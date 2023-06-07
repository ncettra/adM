# Repositorio de Arquitectura de Microprocesadores

Aquí en el readme file se encuentran las respuestas a las preguntas orientadoras propinadas por la catedra.

# # Preguntas orientadoras

# 1. Describa brevemente los diferentes perfiles de familias de microprocesadores/microcontroladores de ARM. Explique alguna de sus diferencias características.

Cortex-A: Esta familia de microprocesadores ARM está diseñada para ofrecer alto rendimiento y se utiliza en dispositivos móviles, tabletas, sistemas multimedia y otros dispositivos con capacidad de procesamiento avanzada. Estos procesadores suelen incluir múltiples núcleos y soportan sistemas operativos complejos, como Android o Linux.

Cortex-R: Esta familia de microprocesadores ARM está diseñada para aplicaciones en tiempo real, como sistemas de control de procesos industriales o sistemas de seguridad de automóviles. Estos procesadores tienen un alto rendimiento y están optimizados para tareas de procesamiento en tiempo real y de baja latencia.

Cortex-M: Esta familia de microcontroladores ARM está diseñada para sistemas embebidos de baja potencia y bajo costo, como sensores, dispositivos de control de acceso y otros sistemas embebidos. Estos microcontroladores tienen una arquitectura simple y están optimizados para un bajo consumo de energía.

# # CORTEX M

# 1. Describa brevemente las diferencias entre las familias de procesadores Cortex M0, M3 y M4.

Cortex M0: Es una familia de microcontroladores de bajo costo y bajo consumo de energía, diseñada para aplicaciones embebidas de bajo rendimiento. Ofrece una arquitectura simple con un conjunto reducido de instrucciones, lo que la hace adecuada para aplicaciones que no requieren un alto nivel de procesamiento. 

Cortex M3: Es una familia de microcontroladores de alto rendimiento diseñada para aplicaciones en tiempo real y de alto rendimiento. Tiene una arquitectura más compleja que el Cortex M0, con un conjunto más amplio de instrucciones y una unidad de coma flotante. 

Cortex M4: Es una familia de microcontroladores de alto rendimiento diseñada para aplicaciones que requieren procesamiento de señales digitales y análisis de datos. Incluye todas las características del Cortex M3, además de una unidad de procesamiento de señales digitales (DSP) y una unidad de coma flotante de precisión simple y doble. 


# 2. ¿Por qué se dice que el set de instrucciones Thumb permite mayor densidad de código?

El conjunto de instrucciones Thumb utiliza instrucciones de 16 bits, lo que lo hace más compacto, esto puede reducir significativamente la cantidad de memoria requerida para almacenar un programa.

# 3. ¿Qué entiende por arquitectura load-store? ¿Qué tipo de instrucciones no posee este tipo de arquitectura?

En una arquitectura load-store, las instrucciones aritméticas y lógicas no pueden acceder directamente a la memoria, sino que operan solo en los datos que están en los registros de la CPU. Esto significa que cualquier operación aritmética o lógica en la memoria debe primero cargar los datos en los registros, realizar la operación y luego almacenar el resultado de vuelta en la memoria.

Algunas de las instrucciones que no se pueden ejecutar directamente en una arquitectura load-store son aquellas que involucran operaciones de lectura o escritura directa en la memoria, como las instrucciones de entrada/salida (I/O), las instrucciones de llamada al sistema y las instrucciones de manipulación de punteros de memoria. Estas instrucciones a menudo requieren el acceso directo a la memoria sin la necesidad de cargar los datos en los registros de la CPU primero.

# 4. ¿Cómo es el mapa de memoria de la familia?

Tiene un modelo de memoria plano y lineal. El mapa de memoria de Cortex-M es relativamente simple y consiste en un espacio de direcciones de 32 bits, esto implica un direccionamiento de 2^32 posibles posiciones (4GB)

# 5. ¿Qué ventajas presenta el uso de los “shadowed pointers” del PSP y el MSP?

El uso de shadowed pointers en los registros MSP y PSP brinda beneficios significativos en términos de seguridad, depuración, tolerancia a fallos y eficiencia en el cambio de contexto. Estas características son valiosas en sistemas embebidos y aplicaciones críticas en tiempo real basadas en la arquitectura ARM Cortex-M.

# 6. Describa los diferentes modos de privilegio y operación del Cortex M, sus relaciones y como se conmuta de uno al otro. Describa un ejemplo en el que se pasa del modo privilegiado a no priviligiado y nuevamente a privilegiado.

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
        
# 7. ¿Qué se entiende por modelo de registros ortogonal? Dé un ejemplo

Un modelo de registros ortogonal permite que los registros de un procesador sean utilizados de manera independiente y flexible, sin restricciones específicas sobre su uso o propósito. Esto brinda libertad al programador para asignar y utilizar los registros según las necesidades del programa, lo que proporciona eficiencia y flexibilidad en la programación.

    Esto se visualiza en un programa escrito en assembly por ejemplo, para la arquitectura ARM Cortex-M, se puede utilizar el registro R0 para almacenar un argumento de una función, el registro R1 para realizar cálculos intermedios, el registro R2 para almacenar un resultado parcial, y así sucesivamente.

# 8. ¿Qué ventajas presenta el uso de intrucciones de ejecución condicional (IT)? Dé un ejemplo.

El uso de instrucciones de ejecución condicional, también conocidas como IT (If-Then), ofrece varias ventajas en términos de eficiencia y ahorro de código en la programación en lenguaje Assembly

    FALTA EL EJEMPLO!! buscar en el set

# 14. ¿Qué es el CMSIS? ¿Qué función cumple? ¿Quién lo provee? ¿Qué ventajas aporta?
El CMSIS es un estándar proporcionado por ARM que ofrece una capa de abstracción de hardware, bibliotecas y herramientas para facilitar el desarrollo de software embebido en microcontroladores Cortex-M. El uso del CMSIS mejora la portabilidad del software, aumenta la eficiencia y productividad, y garantiza la compatibilidad con herramientas de desarrollo.

# 17. ¿Qué es el systick? ¿Por qué puede afirmarse que su implementación favorece la portabilidad de los sistemas operativos embebidos?

El SysTick es un temporizador integrado que proporciona una cuenta descendente hacia cero en función de un reloj de referencia y genera interrupciones cuando llega a cero.
Favorece la portabilidad gracias a su disponibilidad universal, su temporización precisa y flexible. Esto permite que los sistemas operativos se adapten fácilmente a diferentes plataformas y aprovechen las capacidades del temporizador para la gestión de eventos y la temporización precisa.

# 18. ¿Qué funciones cumple la unidad de protección de memoria (MPU)?

Permite establecer políticas de protección y seguridad para la memoria y otros recursos del sistema. La MPU puede dividir la memoria en diferentes regiones y asignar permisos de acceso a cada una de ellas. De esta manera, se pueden prevenir accesos no autorizados a regiones críticas del sistema, proteger los datos del usuario y evitar que se corrompa la memoria. 





