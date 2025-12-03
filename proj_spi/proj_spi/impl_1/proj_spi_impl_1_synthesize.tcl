if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2025.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/User/Desktop/proj_spi/proj_spi"
if {![file exists {C:/Users/User/Desktop/proj_spi/proj_spi/impl_1}]} {
  file mkdir {C:/Users/User/Desktop/proj_spi/proj_spi/impl_1}
}
cd {C:/Users/User/Desktop/proj_spi/proj_spi/impl_1}
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- proj_spi_impl_1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn lse -f "proj_spi_impl_1.cprj" "ramdualpt.cprj" "ramdp8b.cprj" -a "iCE40UP"  -o proj_spi_impl_1_cpe.ldc
# synthesize top design
file delete -force -- proj_spi_impl_1.vm proj_spi_impl_1.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/User/Desktop/proj_spi/proj_spi/impl_1/proj_spi_impl_1_lattice.synproj" -logfile "proj_spi_impl_1_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o proj_spi_impl_1_syn.udb proj_spi_impl_1.vm] [list proj_spi_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
