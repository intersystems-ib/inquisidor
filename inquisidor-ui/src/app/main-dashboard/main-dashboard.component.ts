import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { LegendPosition, NgxChartsModule } from '@swimlane/ngx-charts';
import { IrisService } from '../services/iris.service';
import { FormBuilder, FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { catchError, debounceTime, distinctUntilChanged, from, map, Observable, of, Subject, Subscription, switchMap, tap } from 'rxjs';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatAutocompleteModule, MatAutocompleteSelectedEvent } from '@angular/material/autocomplete';
import { MatOptionModule } from '@angular/material/core';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { Router } from '@angular/router';
import { MatTableDataSource } from '@angular/material/table';
import { ContratanteChartsComponent } from "../contratante-charts/contratante-charts.component";

@Component({
  selector: 'app-main-dashboard',
  standalone: true,
  imports: [CommonModule, NgxChartsModule, ReactiveFormsModule, MatFormFieldModule,
    MatInputModule,
    MatTableModule,
    MatChipsModule,
    MatIconModule,
    MatAutocompleteModule,
    MatOptionModule,
    MatButtonModule,
    MatCardModule,
    MatSelectModule,
    MatProgressSpinnerModule],
  templateUrl: './main-dashboard.component.html',
  styleUrl: './main-dashboard.component.scss'
})
export class MainDashboardComponent implements OnInit{

  empresaSearch = new FormControl('');
  empresas = new FormControl<{ Name: string; NIF: string }[]>([], Validators.required);
  anios = new FormControl<number[]>([], Validators.required);

  resultados: { Name: string; NIF: string }[] = [];
  resultado: any = null;
  listaAnios: number[] = [];

  columnas: string[] = ['ganador', 'total'];
  datosLicitador: Array<any> = [];
  dataSourceLicitador = new MatTableDataSource(this.datosLicitador);
  datosGanador: Array<any> = [];
  dataSourceGanador = new MatTableDataSource(this.datosGanador);

  private searchSub: Subscription;

  colorScheme = {
    domain: ['#1976d2', '#388e3c', '#fbc02d', '#e64a19']
  };

  cargando = true;
  legendPosition: LegendPosition = LegendPosition.Right

  lineChartData = [];

  pieChartData = [];

  barChartData = [];

  constructor(private irisService: IrisService,
    private fb: FormBuilder,
    private router: Router
  ) {

    const currentYear = new Date().getFullYear();
    this.listaAnios = Array.from({ length: 5 }, (_, i) => currentYear - i).reverse();
    
    this.searchSub = this.empresaSearch.valueChanges
      .pipe(
        debounceTime(300),
        distinctUntilChanged(),
        switchMap(term => {
          if (!term || term.length < 3) return of([]);
          return from(this.irisService.getWinners(term)).pipe(
            catchError(() => this.router.navigate(['login']))
          );
        })
      )
      .subscribe(res => {
        this.resultados = res;
      });
  }

  ngOnInit() {
    this.cargando = false;
    this.getDashboardStatistics({"filtros": this.listaAnios});
  }

  ngOnDestroy(): void {
    this.searchSub.unsubscribe();
  }
  
  getDashboardStatistics(filter: any) {
    this.cargando = true;
      this.irisService.getDashboardStatistics(filter).subscribe({
        next: res => {  
          this.datosLicitador = res.contractors;
          this.dataSourceLicitador = new MatTableDataSource(this.datosLicitador);
          this.datosGanador = res.winners;
          this.dataSourceGanador = new MatTableDataSource(this.datosGanador);
          this.lineChartData = res.totals;
        },
        error: err => {
          this.cargando = false;
          console.error(JSON.stringify(err));
          this.router.navigate(['home']);
        }, 
        complete: () =>  {
          this.cargando = false;
        }
      });
    }
}
