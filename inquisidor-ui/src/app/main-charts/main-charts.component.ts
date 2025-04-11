import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { LegendPosition, NgxChartsModule } from '@swimlane/ngx-charts';
import { IrisService } from '../services/iris.service';
import { FormBuilder, FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { catchError, debounceTime, distinctUntilChanged, from, map, Observable, of, Subject, Subscription, switchMap, tap } from 'rxjs';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatChipGrid, MatChipListbox, MatChipOption, MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatAutocompleteModule, MatAutocompleteSelectedEvent } from '@angular/material/autocomplete';
import { MatOptionModule } from '@angular/material/core';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'app-main-charts',
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
    MatSelectModule],
  templateUrl: './main-charts.component.html',
  styleUrl: './main-charts.component.scss'
})
export class MainChartsComponent implements OnInit{

  formulario: FormGroup;
  empresaSearch = new FormControl('');
  empresas = new FormControl<string[]>([], Validators.required);
  anios = new FormControl<number[]>([], Validators.required);

  resultados: string[] = [];
  resultado: any = null;
  listaAnios: number[] = [];

  private searchSub: Subscription;

  colorScheme = {
    domain: ['#1976d2', '#388e3c', '#fbc02d', '#e64a19']
  };

  loading = false;
  legendPosition: LegendPosition = LegendPosition.Below

  lineChartData = [
    {
      name: 'INDRA',
      series: [
        { name: '2020', value: 1200000 },
        { name: '2021', value: 1350000 },
        { name: '2022', value: 1400000 },
        { name: '2023', value: 1550000 },
        { name: '2024', value: 1600000 },
        { name: '2025', value: 1700000 }
      ]
    },
    {
      name: 'Accenture',
      series: [
        { name: '2020', value: 1000000 },
        { name: '2021', value: 1100000 },
        { name: '2022', value: 1150000 },
        { name: '2023', value: 1250000 },
        { name: '2024', value: 1350000 },
        { name: '2025', value: 1450000 }
      ]
    },
    {
      name: 'IBM',
      series: [
        { name: '2020', value: 950000 },
        { name: '2021', value: 1000000 },
        { name: '2022', value: 1050000 },
        { name: '2023', value: 1100000 },
        { name: '2024', value: 1200000 },
        { name: '2025', value: 1300000 }
      ]
    },
    {
      name: 'NTT Data',
      series: [
        { name: '2020', value: 850000 },
        { name: '2021', value: 950000 },
        { name: '2022', value: 1050000 },
        { name: '2023', value: 1150000 },
        { name: '2024', value: 1250000 },
        { name: '2025', value: 1400000 }
      ]
    }
  ];

  pieChartData = [
    { name: 'INDRA', value: 1700000 },
    { name: 'Accenture', value: 1450000 },
    { name: 'IBM', value: 1300000 },
    { name: 'NTT Data', value: 1400000 }
  ];

  barChartData = [
    { name: 'INDRA', value: 8800000 },
    { name: 'Accenture', value: 7500000 },
    { name: 'IBM', value: 6600000 },
    { name: 'NTT Data', value: 6650000 }
  ];

  constructor(private irisService: IrisService,
    private fb: FormBuilder
  ) {

    const currentYear = new Date().getFullYear();
    this.listaAnios = Array.from({ length: currentYear - 2012 + 1 }, (_, i) => 2012 + i);

    this.formulario = this.fb.group({
      empresaSearch: this.empresaSearch,
      empresas: this.empresas,
      anios: this.anios
    });
    
    this.searchSub = this.empresaSearch.valueChanges
      .pipe(
        debounceTime(300),
        distinctUntilChanged(),
        switchMap(term => {
          if (!term || term.length < 3) return of([]);
          return from(this.irisService.getWinners(term)).pipe(
            catchError(() => of([]))
          );
        })
      )
      .subscribe(res => {
        this.resultados = res;
      });
  }

  ngOnInit() {
    //this.getOptions()
    this.loading = false;
  }

  addEmpresa(event: MatAutocompleteSelectedEvent) {
    const nombre = event.option.value;
    if (this.empresas.value != null && !this.empresas.value.includes(nombre)) {
      this.empresas.setValue([...this.empresas.value, nombre]);
    }
    this.empresaSearch.setValue('');
  }

  removeEmpresa(nombre: string) {
    if (this.empresas.value != null){
      this.empresas.setValue(this.empresas.value.filter(e => e !== nombre));
    }
  }

  onSubmit() {
    if (this.formulario.valid) {
      this.resultado = {
        empresas: this.empresas.value,
        anios: this.anios.value
      };
    }
  }

  ngOnDestroy(): void {
    this.searchSub.unsubscribe();
  }
  
}
