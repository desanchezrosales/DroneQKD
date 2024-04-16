///////////////////////////////////////
// DMA test
// Send data from HPS on-chip memory
// to FPGA SRAM
// compile with
// gcc DMA_1.c -o dma  -O3
//
// based on a design from
// https://github.com/robertofem/CycloneVSoC-examples/blob/master/Linux-applications/DMA_transfer_FPGA_DMAC/README.md
//
///////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ipc.h> 
#include <sys/shm.h> 
#include <sys/mman.h>
#include <sys/time.h> 
#include <math.h> 
#include <stdint.h>
#include <errno.h>

// ======================================
#define H2F_AXI_MASTER_BASE   0xC0000000
// main bus; scratch RAM
#define FPGA_PIO_OFFSET       0x10
#define START_PIO_OFFSET      0x20
#define RST_PIO_OFFSET        0x30
#define HW_FPGA_AXI_SPAN (0x40000000)
// h2f bus
// ======================================
// lw_bus; DMA  addresses
#define HW_REGS_BASE        0xff200000
#define HW_REGS_SPAN        0x00005000 
// the h2f light weight bus base
void *h2p_lw_virtual_base;
// the h2f heavy weight bus base
void *h2p_hw_virtual_base;
volatile unsigned int * axi_pio_adr_reg = NULL ;
volatile unsigned int * axi_pio_save_reg = NULL ;	
volatile unsigned int * axi_pio_hps_start = NULL ;
volatile unsigned int * axi_pio_hps_reset = NULL ;
// HPS_to_FPGA DMA address = 0
volatile unsigned int * DMA_status_ptr = NULL ;		
// ======================================
// HPS onchip memory base/span
// 2^16 bytes at the top of memory
#define HPS_ONCHIP_BASE		0xffff0000
#define HPS_ONCHIP_SPAN		0x00010000
// HPS onchip memory (HPS side!)
volatile unsigned int * hps_onchip_ptr = NULL ;
void *hps_onchip_virtual_base;
// ======================================
// HPS linux MMU memory
//int test_array[];
//int data[16384] ;
// ======================================
		  
// WAIT looks nicer than just braces
#define WAIT {}

// /dev/mem file id
int fd;	

// timer variables
struct timeval t1, t2, t3, t4;
double Open2Write_Time, Write2Close_Time, Total_Time;

FILE *file_1;

int k;
char fallocate_buffer[512];
const char* folderName = "data_disk/";
const char* fileName = "data_";
const char* fileType = ".bin";

int n_files = 30;
int file_size = 32;


int main(void)
{
    int f_desc;
    off_t fsize = 1024 * 1024 * file_size; // 32 MB

    for (k = 0; k < n_files; k++) {
        sprintf(fallocate_buffer,"%s%s%d%s",folderName,fileName,k,fileType);

        f_desc = open(fallocate_buffer, O_RDWR | O_CREAT, 0777);
        if (f_desc == -1) {
            perror("open");
            return 1;
        }

        if (fallocate(f_desc, 0, 0, fsize) == -1) {
            perror("fallocate");
            close(f_desc);
            return 1;
        }

        close(f_desc);
    }
    
	// Declare volatile pointers to I/O registers (volatile 	
	// means that IO load and store instructions will be used 	
	// to access these pointer locations, 
	// instead of regular memory loads and stores)  
  
	// === get FPGA addresses ==================
    // Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) 	{
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}
    
	//============================================
    // get virtual addr that maps to physical
	// for light weight bus and heavy weight
	// DMA status register
	h2p_lw_virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );	
	if( h2p_lw_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap1() failed...\n" );
		close( fd );
		return(1);
	}

     // HPS HW
	h2p_hw_virtual_base = mmap( NULL, HW_FPGA_AXI_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, H2F_AXI_MASTER_BASE); 	
	
	if( h2p_hw_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap3() failed...\n" );
		close( fd );
		return(1);
	}

    // HPS onchip ram
	hps_onchip_virtual_base = mmap( NULL, HPS_ONCHIP_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HPS_ONCHIP_BASE); 	
	
	if( hps_onchip_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap3() failed...\n" );
		close( fd );
		return(1);
	}

    // the DMA registers
	DMA_status_ptr = (unsigned int *)(h2p_lw_virtual_base);
    // Get the address that maps to the FPGA PIOs
	axi_pio_adr_reg =(unsigned int *)(h2p_hw_virtual_base);
    axi_pio_save_reg = (unsigned int *)(h2p_hw_virtual_base + FPGA_PIO_OFFSET);
    axi_pio_hps_start = (unsigned int *)(h2p_hw_virtual_base + START_PIO_OFFSET);
    axi_pio_hps_reset = (unsigned int *)(h2p_hw_virtual_base + RST_PIO_OFFSET);
    // Get the address that maps to the HPS ram
	hps_onchip_ptr =(unsigned int *)(hps_onchip_virtual_base);
	
	
	//============================================
	int i;
    int n = 0;
    int previous_state = 0;
    int current_state = 0;

    int previous_save_state = 0;
    int current_save_state = 0;

    unsigned int file_count = 0;
    unsigned int bank_count = 0;
    //unsigned int b_count = 0;
    //uint32_t bank_check[512];
    int total_banks = 0;
    int banks_missed = 0;
    int banks_list[10];

    char filename_buffer[512];
    
    double HPS_save_times_1 [n_files];
    //double HPS_save_times_2 [n_files];
  
    uint32_t *data_buffer = malloc(16384 * 16 * file_size * sizeof(uint32_t));
    if (data_buffer == NULL) {
        // Error handling for failed allocation
        return 1;
    }

    *(axi_pio_hps_start) = 0;
    usleep(10);
    printf("DATA COLLECTION STARTED \n");
    gettimeofday(&t3, NULL);

    *(axi_pio_hps_start) = 1;
    //*(axi_pio_hps_continue) = 1;


    while(file_count < n_files){
        //Print to character buffer
        //while(bank_count < 16*file_size){
            current_state = *(axi_pio_adr_reg);

            if(previous_state == 0 && current_state == 1) 
            {
                //printf("flag 1");
                // section 25.4.3 Tables 224 and 225
                *(DMA_status_ptr) = 0;
                // read bus-master gets data from HPS addr=0xffff0000
                *(DMA_status_ptr+1) = 0x08000000;
                // write bus_master for fpga sram is mapped to 0x08000000 
                *(DMA_status_ptr+2) = 0xffff0000;
                // copy 4000 bytes for 1000 ints
                *(DMA_status_ptr+3) = 16384*4;
                // set bit 2 for WORD transfer
                // set bit 3 to start DMA
                // set bit 7 to stop on byte-count
                // start the timer because DMA will start
                //gettimeofday(&t1, NULL);
                *(DMA_status_ptr+6) = 0b10001100;
                while ((*(DMA_status_ptr) & 0x010) == 0) WAIT;


                ////////////////////////////////SAVE DATA/////////////////////////////////////////////////
                for (i=n; i < n + 16384; i++){
                    data_buffer[i] = *(hps_onchip_ptr+i-n);
                }
                //printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);

                if(data_buffer[i-1] != total_banks){
                    banks_list[banks_missed] = total_banks;
                    printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                    printf("bank_number = %d\n",total_banks);

                    total_banks = data_buffer[i-1];
                    banks_missed++;
                }
                
                ///////////////////////////////////////////////////////////////////////////////////////////       
                bank_count++;
                total_banks++;
                //b_count++;
                previous_state = current_state;
                n = i;
                
            } 

            if(previous_state == 1 && current_state == 2) 
            { 
                //printf("flag 2");
                *(DMA_status_ptr) = 0;
                // read bus-master gets data from HPS addr=0xffff0000
                *(DMA_status_ptr+1) = 0x08010000;
                // write bus_master for fpga sram is mapped to 0x08000000 
                *(DMA_status_ptr+2) = 0xffff0000;
                // copy 4000 bytes for 1000 ints
                *(DMA_status_ptr+3) = 16384*4;
                // set bit 2 for WORD transfer
                // set bit 3 to start DMA
                // set bit 7 to stop on byte-count
                // start the timer because DMA will start
                //gettimeofday(&t1, NULL);
                *(DMA_status_ptr+6) = 0b10001100;
                while ((*(DMA_status_ptr) & 0x010) == 0) WAIT;


                ////////////////////////////////SAVE DATA/////////////////////////////////////
                for (i=n; i < n + 16384; i++){
                    data_buffer[i] = *(hps_onchip_ptr+i-n);
                }

                if(data_buffer[i-1] != total_banks){
                    banks_list[banks_missed] = total_banks;
                    printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                    printf("bank_number = %d\n",total_banks);

                    total_banks = data_buffer[i-1];
                    banks_missed++;
                }
                
                ///////////////////////////////////////////////////////////////////////////////////////////
                bank_count++;
                total_banks++;
                //b_count++; 
                previous_state = current_state; 
                n = i;
            }

             if(previous_state == 2 && current_state == 3) 
            { 
                //printf("flag 2");
                *(DMA_status_ptr) = 0;
                // read bus-master gets data from HPS addr=0xffff0000
                *(DMA_status_ptr+1) = 0x08020000;
                // write bus_master for fpga sram is mapped to 0x08000000 
                *(DMA_status_ptr+2) = 0xffff0000;
                // copy 4000 bytes for 1000 ints
                *(DMA_status_ptr+3) = 16384*4;
                // set bit 2 for WORD transfer
                // set bit 3 to start DMA
                // set bit 7 to stop on byte-count
                // start the timer because DMA will start
                //gettimeofday(&t1, NULL);
                *(DMA_status_ptr+6) = 0b10001100;
                while ((*(DMA_status_ptr) & 0x010) == 0) WAIT;


                ////////////////////////////////SAVE DATA/////////////////////////////////////
                for (i=n; i < n + 16384; i++){
                    data_buffer[i] = *(hps_onchip_ptr+i-n);
                }

                if(data_buffer[i-1] != total_banks){
                    banks_list[banks_missed] = total_banks;
                    printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                    printf("bank_number = %d\n",total_banks);

                    total_banks = data_buffer[i-1];
                    banks_missed++;
                }
                
                ///////////////////////////////////////////////////////////////////////////////////////////
                bank_count++;
                total_banks++;
                //b_count++; 
                previous_state = current_state; 
                n = i;
            }

             if(previous_state == 3 && current_state == 0) 
            { 
                //printf("flag 2");
                *(DMA_status_ptr) = 0;
                // read bus-master gets data from HPS addr=0xffff0000
                *(DMA_status_ptr+1) = 0x08030000;
                // write bus_master for fpga sram is mapped to 0x08000000 
                *(DMA_status_ptr+2) = 0xffff0000;
                // copy 4000 bytes for 1000 ints
                *(DMA_status_ptr+3) = 16384*4;
                // set bit 2 for WORD transfer
                // set bit 3 to start DMA
                // set bit 7 to stop on byte-count
                // start the timer because DMA will start
                //gettimeofday(&t1, NULL);
                *(DMA_status_ptr+6) = 0b10001100;
                while ((*(DMA_status_ptr) & 0x010) == 0) WAIT;


                ////////////////////////////////SAVE DATA/////////////////////////////////////
                for (i=n; i < n + 16384; i++){
                    data_buffer[i] = *(hps_onchip_ptr+i-n);
                }

                if(data_buffer[i-1] != total_banks){
                    banks_list[banks_missed] = total_banks;
                    printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                    printf("bank_number = %d\n",total_banks);

                    total_banks = data_buffer[i-1];
                    banks_missed++;
                }
                
                ///////////////////////////////////////////////////////////////////////////////////////////
                bank_count++;
                total_banks++;
                //b_count++; 
                previous_state = current_state; 
                n = i;
            }

/////////////////////////////////////SAVE 32MB FILE////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
            current_save_state= *(axi_pio_save_reg);

            if(previous_save_state == 0 && current_save_state == 1) 
            {
                gettimeofday(&t1, NULL);
                sprintf(filename_buffer,"%s%s%d%s",folderName,fileName,file_count,fileType);
            
                file_1 = fopen (filename_buffer, "wb");
                fwrite(
                        data_buffer,
                        sizeof(uint32_t),
                        16384*16*file_size,
                        file_1);
                //gettimeofday(&t2, NULL);
                fflush(file_1);
                fclose(file_1);
                gettimeofday(&t2, NULL);

                Open2Write_Time = (t2.tv_sec - t1.tv_sec);      // sec to us
                Open2Write_Time += (t2.tv_usec - t1.tv_usec)/ (double)1000000 ;   // us to 

                HPS_save_times_1 [file_count] = Open2Write_Time;
            
                bank_count = 0;
                n = 0;
                file_count++;

                previous_save_state = current_save_state;

            }

            if(previous_save_state == 1 && current_save_state == 0) 
            {
                previous_save_state = current_save_state;
            }
    }

    *(axi_pio_hps_start) = 0;
    gettimeofday(&t4, NULL);
   

    int file_loop;
    for(file_loop = 0; file_loop < n_files; file_loop++){
            printf("HPS file %d Open to Close T=%lf Sec\n", file_loop, HPS_save_times_1[file_loop]);
        }

    printf("Banks Missed = %d\n", banks_missed*2);
    int loop;
    if(banks_missed > 0){
        for(loop = 0; loop < banks_missed; loop++){
            printf("%d\n", banks_list[loop]);
       }
    }

    Total_Time = (t4.tv_sec - t3.tv_sec);      // sec to us
    Total_Time += (t4.tv_usec - t3.tv_usec)/ (double)1000000 ;   // us to 
    printf("Total Collection Time T=%lf Sec\n", Total_Time);

    return 0;

} // end main