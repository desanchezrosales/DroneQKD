/////////////////////////////////////
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
#define CONTINUE_PIO_OFFSET   0x10
#define START_PIO_OFFSET      0x20
#define ADDR_PIO_OFFSET_0     0x00
#define ADDR_PIO_OFFSET_1     0x30
#define ADDR_PIO_OFFSET_2     0x50
#define ADDR_PIO_OFFSET_3     0x40

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

volatile unsigned int * axi_pio_adr_reg_0 = NULL ;
volatile unsigned int * axi_pio_adr_reg_1 = NULL ;
volatile unsigned int * axi_pio_adr_reg_2 = NULL ;
volatile unsigned int * axi_pio_adr_reg_3 = NULL ;

volatile unsigned int * axi_pio_hps_continue = NULL ;	
volatile unsigned int * axi_pio_hps_start = NULL ;
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
double Open2Write_Time, Data_Time;

FILE *file_1;

int k;
char fallocate_buffer[512];
const char* folderName = "data_disk/";
const char* fileName = "data_";
const char* fileType = ".bin";

int n_files = 1;
int file_size = 200;


int main(void)
{
    int f_desc;
    off_t fsize = 1024*1024*file_size; // 300MB

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
	axi_pio_adr_reg_0 =(unsigned int *)(h2p_hw_virtual_base + ADDR_PIO_OFFSET_0);
    axi_pio_adr_reg_1 =(unsigned int *)(h2p_hw_virtual_base + ADDR_PIO_OFFSET_1);
    axi_pio_adr_reg_2 =(unsigned int *)(h2p_hw_virtual_base + ADDR_PIO_OFFSET_2);
    axi_pio_adr_reg_3 =(unsigned int *)(h2p_hw_virtual_base + ADDR_PIO_OFFSET_3);


    axi_pio_hps_continue = (unsigned int *)(h2p_hw_virtual_base + CONTINUE_PIO_OFFSET);
    axi_pio_hps_start = (unsigned int *)(h2p_hw_virtual_base + START_PIO_OFFSET);
    // Get the address that maps to the HPS ram
	hps_onchip_ptr =(unsigned int *)(hps_onchip_virtual_base);
	
	
	//============================================
	int i;
    int n = 0;

    int previous_state_0 = 0;
    int current_state_0 = 0;
    int previous_state_1 = 0;
    int current_state_1 = 0;
    int previous_state_2 = 0;
    int current_state_2 = 0;
    int previous_state_3 = 0;
    int current_state_3 = 0;


    unsigned int file_count = 0;
    unsigned int bank_count = 0;
    //unsigned int b_count = 0;
    //uint32_t bank_check[512];
    int total_banks_0 = 0;
    int total_banks_1 = 0;
    int total_banks_2 = 0;
    int total_banks_3 = 0;
    
    //int banks_missed = 0;
    //int banks_list[10];

    char filename_buffer[512];
    
    double HPS_save_times_1 [n_files];
    //double HPS_save_times_2 [n_files];
  
    uint32_t *data_buffer = malloc((16384 * 16 * file_size + 16*file_size)* sizeof(uint32_t));
    if (data_buffer == NULL) {
        // Error handling for failed allocation
        return 1;
    }

    *(axi_pio_hps_start) = 1;

    while(file_count < n_files){
        
        gettimeofday(&t3, NULL);

        while(bank_count < 16*file_size){

            current_state_0 = *(axi_pio_adr_reg_0);
            current_state_1 = *(axi_pio_adr_reg_1);
            current_state_2 = *(axi_pio_adr_reg_2);
            current_state_3 = *(axi_pio_adr_reg_3);

            if(previous_state_0 == 0 && current_state_0 == 1) 
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

                // if(data_buffer[i-1] != total_banks_0){
                //     //banks_list[banks_missed] = total_banks;
                //     printf("data_buffer[i-6] = %d\n",data_buffer[i-6]);
                //     printf("data_buffer[i-5] = %d\n",data_buffer[i-5]);
                //     printf("data_buffer[i-4] = %d\n",data_buffer[i-4]);
                //     printf("data_buffer[i-3] = %d\n",data_buffer[i-3]);
                //     printf("data_buffer[i-2] = %d\n",data_buffer[i-2]);
                //     printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                //     printf("total_banks_0 = %d\n",total_banks_0);

                //     total_banks_0 = data_buffer[i-1];
                //     //banks_missed++;
                // }

                // else{
                //     data_buffer[i-1] = 0;
                // }

                data_buffer[i] = 0;

                ///////////////////////////////////////////////////////////////////////////////////////////       
                bank_count++;
                total_banks_0++;
                previous_state_0 = current_state_0;
                n = i + 1;
                
            } 

            if(previous_state_0 == 1 && current_state_0 == 0) 
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

                // if(data_buffer[i-1] != total_banks_0){
                //     //banks_list[banks_missed] = total_banks;
                //     printf("data_buffer[i-6] = %d\n",data_buffer[i-6]);
                //     printf("data_buffer[i-5] = %d\n",data_buffer[i-5]);
                //     printf("data_buffer[i-4] = %d\n",data_buffer[i-4]);
                //     printf("data_buffer[i-3] = %d\n",data_buffer[i-3]);
                //     printf("data_buffer[i-2] = %d\n",data_buffer[i-2]);
                //     printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                //     printf("total_banks_0 = %d\n",total_banks_0);
                    

                //     total_banks_0 = data_buffer[i-1];
                //     //banks_missed++;
                // }

                // else{
                //     data_buffer[i-1] = 0;
                // }

                data_buffer[i] = 0;

                ///////////////////////////////////////////////////////////////////////////////////////////       
                bank_count++;
                total_banks_0++;
                previous_state_0 = current_state_0;
                n = i + 1;
            }

            if(previous_state_1 == 0 && current_state_1 == 1) 
            {
                //printf("flag 1");
                // section 25.4.3 Tables 224 and 225
                *(DMA_status_ptr) = 0;
                // read bus-master gets data from HPS addr=0xffff0000
                *(DMA_status_ptr+1) = 0x00040000;
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

                // if(data_buffer[i-1] != total_banks_1){
                //     //banks_list[banks_missed] = total_banks;
                //     printf("data_buffer[i-6] = %d\n",data_buffer[i-6]);
                //     printf("data_buffer[i-5] = %d\n",data_buffer[i-5]);
                //     printf("data_buffer[i-4] = %d\n",data_buffer[i-4]);
                //     printf("data_buffer[i-3] = %d\n",data_buffer[i-3]);
                //     printf("data_buffer[i-2] = %d\n",data_buffer[i-2]);
                //     printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                //     printf("total_banks_1 = %d\n",total_banks_1);

                //     total_banks_1 = data_buffer[i-1];
                //     //banks_missed++;
                // }

                // else{
                //     data_buffer[i-1] = 1;
                // }

                data_buffer[i] = 1;

                ///////////////////////////////////////////////////////////////////////////////////////////       
                bank_count++;
                total_banks_1++;
                previous_state_1 = current_state_1;
                n = i + 1;
                
            } 

            if(previous_state_1 == 1 && current_state_1 == 0) 
            { 
                //printf("flag 2");
                *(DMA_status_ptr) = 0;
                // read bus-master gets data from HPS addr=0xffff0000
                *(DMA_status_ptr+1) = 0x00050000;
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

                // if(data_buffer[i-1] != total_banks_1){
                //     //banks_list[banks_missed] = total_banks;
                //     printf("data_buffer[i-6] = %d\n",data_buffer[i-6]);
                //     printf("data_buffer[i-5] = %d\n",data_buffer[i-5]);
                //     printf("data_buffer[i-4] = %d\n",data_buffer[i-4]);
                //     printf("data_buffer[i-3] = %d\n",data_buffer[i-3]);
                //     printf("data_buffer[i-2] = %d\n",data_buffer[i-2]);
                //     printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                //     printf("total_banks_1 = %d\n",total_banks_1);

                //     total_banks_1 = data_buffer[i-1];
                //     //banks_missed++;
                // }

                // else{
                //     data_buffer[i-1] = 1;
                // }
                
                data_buffer[i] = 1;

                ///////////////////////////////////////////////////////////////////////////////////////////       
                bank_count++;
                total_banks_1++;
                previous_state_1 = current_state_1;
                n = i + 1;
                
            }

            if(previous_state_2 == 0 && current_state_2 == 1) 
            {
                //printf("flag 1");
                // section 25.4.3 Tables 224 and 225
                *(DMA_status_ptr) = 0;
                // read bus-master gets data from HPS addr=0xffff0000
                *(DMA_status_ptr+1) = 0x00020000;
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

                // if(data_buffer[i-1] != total_banks_2){
                //     //banks_list[banks_missed] = total_banks;
                //     printf("data_buffer[i-6] = %d\n",data_buffer[i-6]);
                //     printf("data_buffer[i-5] = %d\n",data_buffer[i-5]);
                //     printf("data_buffer[i-4] = %d\n",data_buffer[i-4]);
                //     printf("data_buffer[i-3] = %d\n",data_buffer[i-3]);
                //     printf("data_buffer[i-2] = %d\n",data_buffer[i-2]);
                //     printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                //     printf("total_banks_2 = %d\n",total_banks_2);

                //     total_banks_2 = data_buffer[i-1];
                //     //banks_missed++;
                // }

                // else{
                //     data_buffer[i-1] = 2;
                // }
                
                data_buffer[i] = 2;

                ///////////////////////////////////////////////////////////////////////////////////////////       
                bank_count++;
                total_banks_2++;
                previous_state_2 = current_state_2;
                n = i + 1;
                
            } 

            if(previous_state_2 == 1 && current_state_2 == 0) 
            { 
                //printf("flag 2");
                *(DMA_status_ptr) = 0;
                // read bus-master gets data from HPS addr=0xffff0000
                *(DMA_status_ptr+1) = 0x00030000;
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

                // if(data_buffer[i-1] != total_banks_2){
                //     //banks_list[banks_missed] = total_banks;
                //     printf("data_buffer[i-6] = %d\n",data_buffer[i-6]);
                //     printf("data_buffer[i-5] = %d\n",data_buffer[i-5]);
                //     printf("data_buffer[i-4] = %d\n",data_buffer[i-4]);
                //     printf("data_buffer[i-3] = %d\n",data_buffer[i-3]);
                //     printf("data_buffer[i-2] = %d\n",data_buffer[i-2]);
                //     printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                //     printf("total_banks_2 = %d\n",total_banks_2);

                //     total_banks_2 = data_buffer[i-1];
                //     //banks_missed++;
                // }

                // else{
                //     data_buffer[i-1] = 2;
                // }

                data_buffer[i] = 2;
                
                ///////////////////////////////////////////////////////////////////////////////////////////       
                bank_count++;
                total_banks_2++;
                previous_state_2 = current_state_2;
                n = i + 1;
                
            }

            if(previous_state_3 == 0 && current_state_3 == 1) 
            {
                //printf("flag 1");
                // section 25.4.3 Tables 224 and 225
                *(DMA_status_ptr) = 0;
                // read bus-master gets data from HPS addr=0xffff0000
                *(DMA_status_ptr+1) = 0x00000000;
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

                // if(data_buffer[i-1] != total_banks_3){
                //     //banks_list[banks_missed] = total_banks;
                //     printf("data_buffer[i-6] = %d\n",data_buffer[i-6]);
                //     printf("data_buffer[i-5] = %d\n",data_buffer[i-5]);
                //     printf("data_buffer[i-4] = %d\n",data_buffer[i-4]);
                //     printf("data_buffer[i-3] = %d\n",data_buffer[i-3]);
                //     printf("data_buffer[i-2] = %d\n",data_buffer[i-2]);
                //     printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                //     printf("total_banks_3 = %d\n",total_banks_3);

                //     total_banks_3 = data_buffer[i-1];
                //     //banks_missed++;
                // }

                // else{
                //     data_buffer[i-1] = 3;
                // }
                
                data_buffer[i] = 3;

                ///////////////////////////////////////////////////////////////////////////////////////////       
                bank_count++;
                total_banks_3++;
                previous_state_3 = current_state_3;
                n = i + 1;
                
            } 

            if(previous_state_3 == 1 && current_state_3 == 0) 
            { 
                //printf("flag 2");
                *(DMA_status_ptr) = 0;
                // read bus-master gets data from HPS addr=0xffff0000
                *(DMA_status_ptr+1) = 0x00010000;
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

                // if(data_buffer[i-1] != total_banks_3){
                //     //banks_list[banks_missed] = total_banks;
                //     printf("data_buffer[i-6] = %d\n",data_buffer[i-6]);
                //     printf("data_buffer[i-5] = %d\n",data_buffer[i-5]);
                //     printf("data_buffer[i-4] = %d\n",data_buffer[i-4]);
                //     printf("data_buffer[i-3] = %d\n",data_buffer[i-3]);
                //     printf("data_buffer[i-2] = %d\n",data_buffer[i-2]);
                //     printf("data_buffer[i-1] = %d\n",data_buffer[i-1]);
                //     printf("total_banks_3 = %d\n",total_banks_3);

                //     total_banks_3 = data_buffer[i-1];
                //     //banks_missed++;
                // }

                // else{
                //     data_buffer[i-1] = 3;
                // }
                
                data_buffer[i] = 3;

                ///////////////////////////////////////////////////////////////////////////////////////////       
                bank_count++;
                total_banks_3++;
                previous_state_3 = current_state_3;
                n = i + 1;
                
            }
        }
        
        gettimeofday(&t4, NULL);
        Data_Time = (t4.tv_sec - t3.tv_sec);      // sec to us
        Data_Time += (t4.tv_usec - t3.tv_usec)/ (double)1000000 ;   // us to 
        printf("Time to collect data is: %lf Sec\n", Data_Time);

        gettimeofday(&t1, NULL);
        sprintf(filename_buffer,"%s%s%d%s",folderName,fileName,file_count,fileType);
    
        file_1 = fopen (filename_buffer, "wb");
        fwrite(
                data_buffer,
                sizeof(uint32_t),
                16384*16*file_size + 16*file_size,
                file_1);
        //gettimeofday(&t2, NULL);
        fflush(file_1);
        fclose(file_1);
        gettimeofday(&t2, NULL);

        Open2Write_Time = (t2.tv_sec - t1.tv_sec);      // sec to us
        Open2Write_Time += (t2.tv_usec - t1.tv_usec)/ (double)1000000 ;   // us to 

       // Write2Close_Time = (t3.tv_sec - t2.tv_sec) * 1000000.0;      // sec to us
        //Write2Close_Time += (t3.tv_usec - t2.tv_usec) ;   // us to 


        HPS_save_times_1 [file_count] = Open2Write_Time;
        //printf("HPS file %d Open to Close T=%lf Sec\n", file_count, HPS_save_times_1[file_count]);
        //HPS_save_times_2 [file_count] = Write2Close_Time;

        bank_count = 0;
        n = 0;
        file_count++;

        *(axi_pio_hps_continue) = 1;
        
    }

        

    int file_loop;
    for(file_loop = 0; file_loop < n_files; file_loop++){
            printf("HPS file %d Open to Close T=%lf Sec\n", file_loop, HPS_save_times_1[file_loop]);
        }

    // printf("Banks Missed = %d\n", banks_missed*2);
    // int loop;
    // if(banks_missed > 0){
    //     for(loop = 0; loop < banks_missed; loop++){
    //         printf("%d\n", banks_list[loop]);
    //     }
    // }

    // sprintf(filename_buffer,"%s%s%d%s",folderName,fileName,file_count,fileType);
    
    // file_1 = fopen (filename_buffer, "wb");
    // fwrite(
    //         bank_check,
    //         sizeof(uint32_t),
    //         512,
    //         file_1);

    // fclose(file_1);
    return 0;

    
} // end main
	
//////////////////////////////////////////////////////////////////
/// end /////////////////////////////////////