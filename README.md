# Repositorio de Arquitectura de Microprocesadores

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






