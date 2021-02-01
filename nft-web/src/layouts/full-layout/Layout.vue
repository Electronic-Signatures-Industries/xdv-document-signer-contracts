<template>
  <v-app id="inspire">
    <Header v-model="expandOnHover"></Header>
    
    <v-content >
      <v-container>
<issuer-component/>
      </v-container>
    </v-content>
     
    <Footer></Footer> 
    
  </v-app>

</template>

<script>

import IssuerComponent from '../../views/pages/issuer/Issuer.vue'
import Header from './header/Header';
import Sidebar from './sidebar/Sidebar';
import Footer from './footer/Footer';
import { mapState, mapMutations } from 'vuex';
export default {
  name: 'Layout',

  components: {
    Header,
    IssuerComponent,
    Footer,
  },

  props: {
    source: String,
  },
  data: () => ({
    expandOnHover: false
  }),
};
</script>

<style>

</style>