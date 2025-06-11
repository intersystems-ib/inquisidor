import { Component } from '@angular/core';
import { MainListComponent } from "../main-list/main-list.component";
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatListModule } from '@angular/material/list';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { MainChartsComponent } from "../main-charts/main-charts.component";
import { ContratanteChartsComponent } from '../contratante-charts/contratante-charts.component';
import { MainDashboardComponent } from '../main-dashboard/main-dashboard.component';

@Component({
  selector: 'app-home',
  imports: [MainListComponent,
    MainChartsComponent,
    ContratanteChartsComponent,
    MainDashboardComponent,
    CommonModule,
    MatSidenavModule,
    MatToolbarModule,
    MatIconModule,
    MatButtonModule,
    MatListModule, MainChartsComponent],
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss'
})
export class HomeComponent {
  opened = false;
  show = ""

  constructor( private router: Router){

  }

  toggleSidenav(sidenav: any) {
    sidenav.toggle();
  }
}
