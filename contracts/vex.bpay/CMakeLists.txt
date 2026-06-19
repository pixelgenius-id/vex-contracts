add_contract(vex.bpay vex.bpay ${CMAKE_CURRENT_SOURCE_DIR}/src/vex.bpay.cpp)

target_include_directories(vex.bpay PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include
   ${CMAKE_CURRENT_SOURCE_DIR}/../vexcore/include
   ${CMAKE_CURRENT_SOURCE_DIR}/../vex.token/include)

set_target_properties(vex.bpay
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/vex.bpay.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/vex.bpay.contracts.md @ONLY )

target_compile_options( vex.bpay PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )
