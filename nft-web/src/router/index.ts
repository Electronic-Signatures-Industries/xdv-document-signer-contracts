import Vue from 'vue'
import VueRouter, { RouteConfig } from 'vue-router'
import IssuerComponent from '../views/pages/issuer/Issuer.vue'

Vue.use(VueRouter)

const routes: Array<RouteConfig> = [
  {
    path: "/",
    component: () => import('../layouts/full-layout/Layout.vue'),

    children: [
      {
        path: "/issuer",
        name: "issuer",
        component: IssuerComponent,
      },
      // {
      //   path: "certs",
      //   name: "certs",
      //   component: CertificatesComponent,
      // },
    ]
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
