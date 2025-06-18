#### Define cell usage during CTS

foreach stren {1 2 4 8 16 20} {
    set_lib_cell_purpose -include cts */SAEDRVT14_INV_${stren}
}
foreach stren {2 4 6 8 16 20} {
    set_lib_cell_purpose -include cts */SAEDRVT14_BUF_${stren}
}
