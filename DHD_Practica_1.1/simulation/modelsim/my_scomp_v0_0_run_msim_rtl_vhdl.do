transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/ELVIRA/Desktop/3CursoETSIIT/2CUATRI/DHD/practicas/DHD_Practica_1.1/procesador_v0_0.vhd}
vcom -93 -work work {C:/Users/ELVIRA/Desktop/3CursoETSIIT/2CUATRI/DHD/practicas/DHD_Practica_1.1/my_scomp_v0_0.vhd}
vcom -93 -work work {C:/Users/ELVIRA/Desktop/3CursoETSIIT/2CUATRI/DHD/practicas/DHD_Practica_1.1/IP_ram_256_x_16.vhd}

