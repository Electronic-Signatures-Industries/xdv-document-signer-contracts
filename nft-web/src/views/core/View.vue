<template>
    <v-main fluid>
      <router-view  />
    </v-main>
</template>

<script lang="ts">
import { Component, Vue } from "vue-property-decorator";

@Component({
  name: "DashboardCoreView",
  components: {
    DashboardCoreFooter: () => import("./Footer.vue")
  }
})
export default class DashboardCoreView extends Vue {
  solidoProps = null;
  async mounted() {
    debugger
  }
   // this.$router.push({ path: 'wallet' });
 
}
</script>
