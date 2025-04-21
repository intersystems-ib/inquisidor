import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { LegendPosition, NgxChartsModule } from '@swimlane/ngx-charts';
import { IrisService } from '../services/iris.service';
import { FormBuilder, FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { catchError, debounceTime, distinctUntilChanged, from, map, Observable, of, Subject, Subscription, switchMap, tap } from 'rxjs';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatChipListbox, MatChipOption, MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatAutocompleteModule, MatAutocompleteSelectedEvent } from '@angular/material/autocomplete';
import { MatOptionModule } from '@angular/material/core';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { Router } from '@angular/router';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-contratante-charts',
  standalone: true,
  imports: [CommonModule, NgxChartsModule, ReactiveFormsModule,MatFormFieldModule,
    MatInputModule,
    MatChipsModule,
    MatIconModule,
    MatAutocompleteModule,
    MatOptionModule,
    MatChipListbox,
    MatChipOption,
    MatButtonModule,
    MatSelectModule,
    MatProgressSpinnerModule],
  templateUrl: './contratante-charts.component.html',
  styleUrl: './contratante-charts.component.scss'
})
export class ContratanteChartsComponent implements OnInit{

  formulario: FormGroup;
  contratanteSearch = new FormControl('');
  contratantes = new FormControl<string[]>([], Validators.required);
  anios = new FormControl<number[]>([], Validators.required);

  resultados: string[] = [];
  resultado: any = null;
  listaAnios: number[] = [];

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
    this.listaAnios = Array.from({ length: currentYear - 2012 + 1 }, (_, i) => 2012 + i);

    this.formulario = this.fb.group({
      contratanteSearch: this.contratanteSearch,
      contratantes: this.contratantes,
      anios: this.anios
    });
    
    this.searchSub = this.contratanteSearch.valueChanges
      .pipe(
        debounceTime(300),
        distinctUntilChanged(),
        switchMap(term => {
          if (!term || term.length < 3) return of([]);
          return from(this.irisService.getContractors(term)).pipe(
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
  }

  addContratante(event: MatAutocompleteSelectedEvent) {
    const nombre = event.option.value;

    if (!this.contratantes.value?.includes(nombre)) {
      this.contratantes.setValue([...this.contratantes.value ?? [], nombre]);
    }

    this.contratanteSearch.setValue('');
  }

  removeContratante(nombre: string) {
    this.contratantes.setValue((this.contratantes.value ?? []).filter(e => e !== nombre));
  }

  onSubmit() {
    if (this.formulario.valid) {
      this.resultado = {
        contratantes: this.contratantes.value,
        anios: this.anios.value
      };
      this.getStatisticsContractors({"filtros": this.resultado});
    }
  }

  ngOnDestroy(): void {
    this.searchSub.unsubscribe();
  }
  
  getStatisticsContractors(filter: any) {
    this.cargando = true;
    this.irisService.getStatisticsContractors(filter).subscribe({
      next: res => {  
        this.lineChartData = res.lineal;
        this.pieChartData = res.pie;
        this.barChartData = res.pie;
      },
      error: err => {
        console.error(JSON.stringify(err));
        this.router.navigate(['login']);
      }, 
      complete: () =>  {
        this.cargando = false;
      }
    });
  }
}
