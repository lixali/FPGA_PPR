################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/xmt_common.c \
../src/xmt_main.c \
../src/xmt_read_eye.c \
../src/xmt_write_eye.c 

OBJS += \
./src/xmt_common.o \
./src/xmt_main.o \
./src/xmt_read_eye.o \
./src/xmt_write_eye.o 

C_DEPS += \
./src/xmt_common.d \
./src/xmt_main.d \
./src/xmt_read_eye.d \
./src/xmt_write_eye.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v8 gcc compiler'
	aarch64-none-elf-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -IC:/Users/Lixiang/workspace/ultra96_test/export/ultra96_test/sw/ultra96_test/standalone_domain/bspinclude/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


