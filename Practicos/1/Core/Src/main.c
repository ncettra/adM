/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2022 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "string.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "asm_func.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

ETH_TxPacketConfig TxConfig;
ETH_DMADescTypeDef  DMARxDscrTab[ETH_RX_DESC_CNT]; /* Ethernet Rx DMA Descriptors */
ETH_DMADescTypeDef  DMATxDscrTab[ETH_TX_DESC_CNT]; /* Ethernet Tx DMA Descriptors */

ETH_HandleTypeDef heth;

UART_HandleTypeDef huart3;

PCD_HandleTypeDef hpcd_USB_OTG_FS;

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_ETH_Init(void);
static void MX_USART3_UART_Init(void);
static void MX_USB_OTG_FS_PCD_Init(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
static void PrivilegiosSVC (void)
{
    // Obtiene valor del registro de 32 bits del procesador llamado "control".
    // El registro guarda los siguientes estados:
    // bit 2: Uso de FPU en el contexto actual. Usado=1, no usado=0.
    // bit 1: Mapeo del stack pointer(sp). MSP=0, PSP=1.
    // bit 0: Modo de ejecucion en Thread. Privilegiado=0, No privilegiado=1.
    //        Recordar que este valor solo se usa en modo Thread. Las
    //        interrupciones siempre se ejecutan en modo Handler con total
    //        privilegio.
    uint32_t x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    //__BKPT (0);

    x |= 1;
    // bit 0 a modo No privilegiado.
    __set_CONTROL (x);

    // En este punto se estaria ejecutando en modo No privilegiado.
    // Lectura del registro "control" para confirmar.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    //__BKPT (0);

    x &= ~1u;
    // Se intenta volver a modo Privilegiado (bit 0, valor 0).
    __set_CONTROL (x);

    // Confirma que esta operacion es ignorada por estar ejecutandose en modo
    // Thread no privilegiado.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    //__BKPT (0);

    // En este punto, ejecutando en modo Thread no privilegiado, la unica forma
    // de volver a modo privilegiado o de realizar cualquier cambio que requiera
    // modo privilegiado, es pidiendo ese servicio a un hipotetico sistema
    // opertivo de tiempo real.
    // Para esto se invoca por software a la interrupcion SVC (Supervisor Call)
    // utilizando la instruccion "svc".
    // No hay intrinsics para realizar esta tarea. Para utilizar la instruccion
    // es necesario implementar una funcion en assembler. Ver el archivo
    // asm_func.S.
    asm_svc ();

    // El sistema operativo (el handler de SVC) deberia haber devuelto el modo
    // de ejecucion de Thread a privilegiado (bit 0 en valor 0).
    x = __get_CONTROL ();

    // Fin del ejemplo de SVC
}


void zeros(uint32_t *vector, uint32_t longitud) {
    for (uint32_t i = 0; i < longitud; i++) {
        vector[i] = 0;
    }
}
//optimizado, dsp aplicar en todos.....:
void zeros_optimizada(uint32_t *vector, uint32_t longitud) {
    for (; longitud >0; longitud--) {
        vector[longitud-1] = 0;
    }
}
void productoEscalar32(uint32_t *vectorIn, uint32_t *vectorOut, uint32_t longitud, uint32_t escalar) {
    for (uint32_t i = 0; i < longitud; i++) { //en clase no utilizaron la variable auxiliar i,
        vectorOut[i] = vectorIn[i] * escalar;
    }
}
void productoEscalar16(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud, uint16_t escalar) {
    for (uint32_t i = 0; i < longitud; i++) {
        vectorOut[i] = vectorIn[i] * escalar;
    }
}
void productoEscalar12(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud, uint16_t escalar) {
    for (uint32_t i = 0; i < longitud; i++) {
        uint32_t resultado = (uint32_t)vectorIn[i] * (uint32_t)escalar;
        if (resultado > 0xFFF) {
            vectorOut[i] = 0xFFF; // Saturación a 12 bits
        } else {
            vectorOut[i] = (uint16_t)resultado;
        }
    }
}
void filtroVentana10(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud) {
    int32_t p;
    const uint8_t SampleOffset = 5;
    const uint8_t WindowSize = (SampleOffset * 2) + 1;

    for (int32_t i = longitud - 1; i >= 0; i--) {
        p = i;
        vectorOut[p] = 0;

        for (int32_t j = p + SampleOffset; j >= p - SampleOffset; j--) {
            if (j < longitud && j >= 0) {
                vectorOut[p] += vectorIn[j];
            }
        }
        vectorOut[p] /= WindowSize;
    }
}
void pack32to16(int32_t *vectorIn, int16_t *vectorOut, uint32_t longitud) {
    for (uint32_t i = 0; i < longitud; i++) {
        vectorOut[i] = (int16_t)(vectorIn[i] >> 16);
    }
}
int32_t max(int32_t *vectorIn, uint32_t longitud) {
    int32_t maxValor = vectorIn[0];
    uint32_t maxPosicion = 0;

    for (uint32_t i = 1; i < longitud; i++) {
        if (vectorIn[i] > maxValor) {
            maxValor = vectorIn[i];
            maxPosicion = i;
        }
    }

    return maxPosicion;
}
void downsampleM(int32_t *vectorIn, int32_t *vectorOut, uint32_t longitud, uint32_t N) {
    uint32_t i;
    uint32_t j = 0;

    for (i = 0; i < longitud; i += N) {
        vectorOut[j] = vectorIn[i];
        j++;
    }
}
void invertir(uint16_t *vector, uint32_t longitud) {
    uint32_t i;
    uint16_t temp;

    for (i = 0; i < longitud / 2; i++) {
        temp = vector[i];
        vector[i] = vector[longitud - i - 1];
        vector[longitud - i - 1] = temp;
    }
}
void introducirEco(int16_t *vector, int16_t *vectorOut) {
    uint32_t retrasoMuestras = 882; // 20ms de retraso = 882 muetras
    uint32_t longitud = 4096;
    int16_t mitadAmplitud = 0;

    //SIN ECO
    for (uint32_t i = 0; i < retrasoMuestras; i++) {
        vectorOut[i] = vector[i];
    }

    //ECO
    for (uint32_t i = retrasoMuestras; i < longitud; i++) {
        mitadAmplitud = vector[i - retrasoMuestras] / 2; //retraso
        vectorOut[i] += vector[i] + mitadAmplitud;
    }

}
void introducirEco_Intrinsic(int16_t *vector, int16_t *vectorOut) {
    uint32_t retrasoMuestras = 882; // 20ms de retraso = 882 muetras
    uint32_t longitud = 4096;
    int16_t mitadAmplitud = 0;

    //SIN ECO
    for (uint32_t i = 0; i < retrasoMuestras; i++) {
        vectorOut[i] = vector[i];
    }

    //ECO
    for (uint32_t i = retrasoMuestras; i < longitud; i++) {
        mitadAmplitud = vector[i - retrasoMuestras] / 2; //retraso
        vectorOut[i] = __QADD16(vectorOut[i], __QADD16(vector[i], mitadAmplitud));
    }

}
void corr(int16_t *vectorX, int16_t *vectorY, int16_t *vectorCorr, uint32_t longitud) {
    uint32_t i, j;

    for (i = 0; i < longitud; i++) {
        vectorCorr[i] = 0;
        for (j = 0; j < longitud; j++) {
            if (i + j < longitud) {
                vectorCorr[i] += vectorX[i + j] * vectorY[j];
            }
        }
    }
}
void corr_Intrinsic(int16_t *vectorX, int16_t *vectorY, int16_t *vectorCorr, uint32_t longitud) {
    uint32_t i, j;

    for (i = 0; i < longitud; i++) {
        vectorCorr[i] = 0;
        for (j = 0; j < longitud; j++) {
            if (i + j < longitud) {
                vectorCorr[i] += (int16_t)__SMLAD(vectorX[i + j], vectorY[j], vectorCorr[i]);
            }
        }
    }
}
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_ETH_Init();
  MX_USART3_UART_Init();
  MX_USB_OTG_FS_PCD_Init();
  /* USER CODE BEGIN 2 */
  PrivilegiosSVC ();
  DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos; //activar el contador

  uint32_t ciclosASM,ciclosC,ciclosC2;

  //const uint32_t Resultado = asm_sum (5, 3);


  /*
   * 	EJERCICIO 1 PRUEBA DE FUNCIONES EN C y ASM
   *
   * */
  uint32_t resultado[10] = {10,20,10,40,50,60,20,10,20,40};
  DWT->CYCCNT = 0;  asm_zeros(resultado, 10);  ciclosASM = DWT->CYCCNT;
  DWT->CYCCNT = 0;  zeros(resultado, 10);  ciclosC = DWT->CYCCNT;
  DWT->CYCCNT = 0;  zeros_optimizada(resultado, 10);  ciclosC2 = DWT->CYCCNT;
  /*
   * 	EJERCICIO 2 PRUEBA DE FUNCIONES EN C y ASM
   *
   * */
  uint32_t vectorIN_ej2[10] = {10,20,10,40,50,60,70,80,90,100};
  uint32_t vectorOUT_ej2[10] = {0};
  uint32_t longitud_ej2 = 10, escalar_ej2 = 2;
  DWT->CYCCNT = 0;  asm_productoEscalar32(vectorIN_ej2,vectorOUT_ej2,longitud_ej2,escalar_ej2);  ciclosASM = DWT->CYCCNT;
  DWT->CYCCNT = 0;  productoEscalar32(vectorIN_ej2,vectorOUT_ej2,longitud_ej2,escalar_ej2);  ciclosC = DWT->CYCCNT;
  /*
   * 	EJERCICIO 3 PRUEBA DE FUNCIONES EN C y ASM
   *
   * */
  uint16_t vectorIN_ej3[5] = {10,20,10,40,50};
  uint16_t vectorOUT_ej3[5] = {0};
  uint32_t longitud_ej3 = 5;
  uint16_t escalar_ej3 = 2;
  DWT->CYCCNT = 0;  asm_productoEscalar16(vectorIN_ej3,vectorOUT_ej3,longitud_ej3,escalar_ej3);  ciclosASM = DWT->CYCCNT;
  DWT->CYCCNT = 0;  productoEscalar16(vectorIN_ej3,vectorOUT_ej3,longitud_ej3,escalar_ej3);  ciclosC = DWT->CYCCNT;
  /*
   * 	EJERCICIO 4 PRUEBA DE FUNCIONES EN C y ASM
   *
   * */
  uint16_t vectorIN_ej4[5] = {10000,10000,10000,10000,10000};
  uint16_t vectorOUT_ej4[5] = {0};
  uint32_t longitud_ej4 = 5;
  uint16_t escalar_ej4 = 6;
  DWT->CYCCNT = 0;  asm_productoEscalar12(vectorIN_ej4,vectorOUT_ej4,longitud_ej4,escalar_ej4);  ciclosASM = DWT->CYCCNT;
  DWT->CYCCNT = 0;  productoEscalar12(vectorIN_ej4,vectorOUT_ej4,longitud_ej4,escalar_ej4);  ciclosC = DWT->CYCCNT;
  /*
   * 	EJERCICIO 5 PRUEBA DE FUNCIONES EN C y ASM
   *
   * */
  uint16_t vectorIN_ej5[10] = {1,2,3,4,5,6,7,8,9};
  uint16_t vectorOUT_ej5[10] = {0};
  uint32_t longitud_ej5 = 10;
  DWT->CYCCNT = 0;  asm_filtroVentana10(vectorIN_ej5,vectorOUT_ej5,longitud_ej5);  ciclosASM = DWT->CYCCNT;
  DWT->CYCCNT = 0;  filtroVentana10(vectorIN_ej5,vectorOUT_ej5,longitud_ej5);  ciclosC = DWT->CYCCNT;
  /*
   * 	EJERCICIO 6 PRUEBA DE FUNCIONES EN C y ASM
   *
   * */
  uint32_t vectorIN_ej6[5] = {0xFFFF,0xFEFF,0xEAFF,0xE9FF,0x01FF};
  uint32_t vectorOUT_ej6[5] = {0};
  uint32_t longitud_ej6 = 5;
  DWT->CYCCNT = 0;  asm_pack32to16(vectorIN_ej6,vectorOUT_ej6,longitud_ej6);  ciclosASM = DWT->CYCCNT;
  DWT->CYCCNT = 0;  pack32to16(vectorIN_ej6,vectorOUT_ej6,longitud_ej6);  ciclosC = DWT->CYCCNT;
  /*
   * 	EJERCICIO 7 PRUEBA DE FUNCIONES EN C y ASM
   *
   * */
  uint32_t vectorIN_ej7[10] = {1,2,3,5,4,8,2,3,5,0};
  uint32_t longitud_ej7 = 10;
  DWT->CYCCNT = 0;  uint32_t pos = asm_max32(vectorIN_ej7,longitud_ej7);  ciclosASM = DWT->CYCCNT;
  DWT->CYCCNT = 0;  uint32_t pos2 = max(vectorIN_ej7,longitud_ej7);  ciclosC = DWT->CYCCNT;
  /*
   * 	EJERCICIO 8 PRUEBA DE FUNCIONES EN C y ASM
   *
   * */
  uint32_t vectorIN_ej8[10] = {1,2,3,4,5,6,7,8,9,10};
  uint32_t vectorOUT_ej8[10] = {0};
  uint32_t longitud_ej8 = 10;
  uint32_t N = 2;
  DWT->CYCCNT = 0;  asm_downsampleM(vectorIN_ej8,vectorOUT_ej8,longitud_ej8,N);  ciclosASM = DWT->CYCCNT;
  DWT->CYCCNT = 0;  downsampleM(vectorIN_ej8,vectorOUT_ej8,longitud_ej8,N);  ciclosC = DWT->CYCCNT;
  /*
   * 	EJERCICIO 9 PRUEBA DE FUNCIONES EN C y ASM
   *
   * */
  uint16_t vectorIN_ej9[10] = {1,2,3,4,5,6,7,8,9,10};
  uint32_t longitud_ej9 = 10;
  DWT->CYCCNT = 0;  asm_invertir(vectorIN_ej9,longitud_ej9);  ciclosASM = DWT->CYCCNT;
  DWT->CYCCNT = 0;  invertir(vectorIN_ej9,longitud_ej9);  ciclosC = DWT->CYCCNT;
  int16_t muestras[4096];
  int16_t muestras_eco[4096];

 //prueba de eco, no hago una funcion asm con SIMD porque no encuentro donde aplicarlo eficientemente
  muestras[0] = 10;  muestras[1] = 15;  muestras[2] = 20;  muestras[3] = 25;
  muestras[882] = 10;  muestras[883] = 20;  muestras[884] = 30;  muestras[885] = 40;
  muestras_eco[882] = 0;  muestras_eco[883] = 0;  muestras_eco[884] = 0;  muestras_eco[885] = 0;
  DWT->CYCCNT = 0;  asm_eco(muestras, muestras_eco);  ciclosASM = DWT->CYCCNT;

  muestras[0] = 10;  muestras[1] = 15;  muestras[2] = 20;  muestras[3] = 25;
  muestras[882] = 10;  muestras[883] = 20;  muestras[884] = 30;  muestras[885] = 40;
  muestras_eco[882] = 0;  muestras_eco[883] = 0;  muestras_eco[884] = 0;  muestras_eco[885] = 0;
  DWT->CYCCNT = 0;  introducirEco(muestras, muestras_eco);  ciclosC = DWT->CYCCNT;

  muestras[0] = 10;  muestras[1] = 15;  muestras[2] = 20;  muestras[3] = 25;
  muestras[882] = 10;  muestras[883] = 20;  muestras[884] = 30;  muestras[885] = 40;
  muestras_eco[882] = 0;  muestras_eco[883] = 0;  muestras_eco[884] = 0;  muestras_eco[885] = 0;
  DWT->CYCCNT = 0;  introducirEco_Intrinsic(muestras, muestras_eco);  ciclosC = DWT->CYCCNT;
  /*
   * 	EJERCICIO 10 PRUEBA DE FUNCIONES EN C y ASM
   *
   * */
	uint32_t longitude = 15;
	int16_t vX[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -2, -3, -4, -5};
	int16_t vY[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -2, -3, -4, -5};
	int16_t vOut[longitude];
	DWT->CYCCNT = 0;    corr(vX, vY, vOut, longitude);    ciclosC = DWT->CYCCNT;
	DWT->CYCCNT = 0;	corr_Intrinsic(vX, vY, vOut, longitude);    ciclosC = DWT->CYCCNT;
	//DWT->CYCCNT = 0;    asm_calcularCorrelacion(vX, vY, vOut, longitude);    ciclosASM = DWT->CYCCNT;



  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_BYPASS;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 4;
  RCC_OscInitStruct.PLL.PLLN = 168;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 7;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief ETH Initialization Function
  * @param None
  * @retval None
  */
static void MX_ETH_Init(void)
{

  /* USER CODE BEGIN ETH_Init 0 */

  /* USER CODE END ETH_Init 0 */

   static uint8_t MACAddr[6];

  /* USER CODE BEGIN ETH_Init 1 */

  /* USER CODE END ETH_Init 1 */
  heth.Instance = ETH;
  MACAddr[0] = 0x00;
  MACAddr[1] = 0x80;
  MACAddr[2] = 0xE1;
  MACAddr[3] = 0x00;
  MACAddr[4] = 0x00;
  MACAddr[5] = 0x00;
  heth.Init.MACAddr = &MACAddr[0];
  heth.Init.MediaInterface = HAL_ETH_RMII_MODE;
  heth.Init.TxDesc = DMATxDscrTab;
  heth.Init.RxDesc = DMARxDscrTab;
  heth.Init.RxBuffLen = 1524;

  /* USER CODE BEGIN MACADDRESS */

  /* USER CODE END MACADDRESS */

  if (HAL_ETH_Init(&heth) != HAL_OK)
  {
    Error_Handler();
  }

  memset(&TxConfig, 0 , sizeof(ETH_TxPacketConfig));
  TxConfig.Attributes = ETH_TX_PACKETS_FEATURES_CSUM | ETH_TX_PACKETS_FEATURES_CRCPAD;
  TxConfig.ChecksumCtrl = ETH_CHECKSUM_IPHDR_PAYLOAD_INSERT_PHDR_CALC;
  TxConfig.CRCPadCtrl = ETH_CRC_PAD_INSERT;
  /* USER CODE BEGIN ETH_Init 2 */

  /* USER CODE END ETH_Init 2 */

}

/**
  * @brief USART3 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART3_UART_Init(void)
{

  /* USER CODE BEGIN USART3_Init 0 */

  /* USER CODE END USART3_Init 0 */

  /* USER CODE BEGIN USART3_Init 1 */

  /* USER CODE END USART3_Init 1 */
  huart3.Instance = USART3;
  huart3.Init.BaudRate = 115200;
  huart3.Init.WordLength = UART_WORDLENGTH_8B;
  huart3.Init.StopBits = UART_STOPBITS_1;
  huart3.Init.Parity = UART_PARITY_NONE;
  huart3.Init.Mode = UART_MODE_TX_RX;
  huart3.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart3.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart3) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART3_Init 2 */

  /* USER CODE END USART3_Init 2 */

}

/**
  * @brief USB_OTG_FS Initialization Function
  * @param None
  * @retval None
  */
static void MX_USB_OTG_FS_PCD_Init(void)
{

  /* USER CODE BEGIN USB_OTG_FS_Init 0 */

  /* USER CODE END USB_OTG_FS_Init 0 */

  /* USER CODE BEGIN USB_OTG_FS_Init 1 */

  /* USER CODE END USB_OTG_FS_Init 1 */
  hpcd_USB_OTG_FS.Instance = USB_OTG_FS;
  hpcd_USB_OTG_FS.Init.dev_endpoints = 4;
  hpcd_USB_OTG_FS.Init.speed = PCD_SPEED_FULL;
  hpcd_USB_OTG_FS.Init.dma_enable = DISABLE;
  hpcd_USB_OTG_FS.Init.phy_itface = PCD_PHY_EMBEDDED;
  hpcd_USB_OTG_FS.Init.Sof_enable = ENABLE;
  hpcd_USB_OTG_FS.Init.low_power_enable = DISABLE;
  hpcd_USB_OTG_FS.Init.lpm_enable = DISABLE;
  hpcd_USB_OTG_FS.Init.vbus_sensing_enable = ENABLE;
  hpcd_USB_OTG_FS.Init.use_dedicated_ep1 = DISABLE;
  if (HAL_PCD_Init(&hpcd_USB_OTG_FS) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USB_OTG_FS_Init 2 */

  /* USER CODE END USB_OTG_FS_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
/* USER CODE BEGIN MX_GPIO_Init_1 */
/* USER CODE END MX_GPIO_Init_1 */

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOG_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOB, LD1_Pin|LD3_Pin|LD2_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(USB_PowerSwitchOn_GPIO_Port, USB_PowerSwitchOn_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin : USER_Btn_Pin */
  GPIO_InitStruct.Pin = USER_Btn_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(USER_Btn_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : LD1_Pin LD3_Pin LD2_Pin */
  GPIO_InitStruct.Pin = LD1_Pin|LD3_Pin|LD2_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pin : USB_PowerSwitchOn_Pin */
  GPIO_InitStruct.Pin = USB_PowerSwitchOn_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(USB_PowerSwitchOn_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pin : USB_OverCurrent_Pin */
  GPIO_InitStruct.Pin = USB_OverCurrent_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(USB_OverCurrent_GPIO_Port, &GPIO_InitStruct);

/* USER CODE BEGIN MX_GPIO_Init_2 */
/* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
