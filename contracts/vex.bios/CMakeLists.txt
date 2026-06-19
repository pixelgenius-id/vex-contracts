add_contract(vex.bios vex.bios ${CMAKE_CURRENT_SOURCE_DIR}/src/vex.bios.cpp)

target_include_directories(vex.bios
   PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include)

set_target_properties(vex.bios
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/vex.bios.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/vex.bios.contracts.md @ONLY )

target_compile_options( vex.bios PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )
