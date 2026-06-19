#pragma once

#include <eosio/asset.hpp>
#include <eosio/eosio.hpp>
#include <vexcore/vexcore.hpp>

#include <string>

namespace eosiosystem {
   class system_contract;
}

namespace eosio {

   using std::string;
   /**
    * The vex.fees smart contract facilitates the collection of transaction fees from system accounts and their subsequent distribution to the Resource Exchange (REX) pool.
    *
    * This contract serves as an essential component for inclusion in system-level unit tests.
    *
    * A comprehensive implementation of the vex.fees contract can be accessed at EOS Network Foundation GitHub repository.
    * https://github.com/eosnetworkfoundation/vex.fees
    */
   class [[eosio::contract("vex.fees")]] fees : public contract {
      public:
         using contract::contract;

         [[eosio::on_notify("vex.token::transfer")]]
         void on_transfer( const name from, const name to, const asset quantity, const string memo );

         [[eosio::action]]
         void noop();
   };

}
