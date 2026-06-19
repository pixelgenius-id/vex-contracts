add_contract(vex.msig vex.msig ${CMAKE_CURRENT_SOURCE_DIR}/src/vex.msig.cpp)

target_include_directories(vex.msig
   PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include)

set_target_properties(vex.msig
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/vex.msig.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/vex.msig.contracts.md @ONLY )

target_compile_options( vex.msig PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )
