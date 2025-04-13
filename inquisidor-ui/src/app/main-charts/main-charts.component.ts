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
  empresas = new FormControl<{ Name: string; NIF: string }[]>([], Validators.required);
  anios = new FormControl<number[]>([], Validators.required);

  resultados: { Name: string; NIF: string }[] = [];
  resultado: any = null;
  listaAnios: number[] = [];

  private searchSub: Subscription;

  colorScheme = {
    domain: ['#1976d2', '#388e3c', '#fbc02d', '#e64a19']
  };

  loading = false;
  legendPosition: LegendPosition = LegendPosition.Below

  lineChartData = [];

  pieChartData = [];

  barChartData = [];

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
    this.loading = false;
  }

  addEmpresa(event: MatAutocompleteSelectedEvent) {
    const seleccionada = event.option.value as { Name: string; NIF: string };

    const yaSeleccionadas = this.empresas.value ?? [];
    const yaExiste = yaSeleccionadas.some(e => e.NIF === seleccionada.NIF);

    if (!yaExiste) {
      this.empresas.setValue([...yaSeleccionadas, seleccionada]);
    }

    this.empresaSearch.setValue('');
  }

  removeEmpresa(nif: string) {
    const actuales = this.empresas.value ?? [];
    this.empresas.setValue(actuales.filter(e => e.NIF !== nif));
  }

  onSubmit() {
    if (this.formulario.valid) {
      this.resultado = {
        empresas: this.empresas.value,
        anios: this.anios.value
      };
      this.getStatistics({"filtros": this.resultado});
    }
  }

  ngOnDestroy(): void {
    this.searchSub.unsubscribe();
  }
  
  getStatistics(filter: any) {
      this.irisService.getStatistics(filter).subscribe({
        next: res => {  
          this.lineChartData = res.lineal;
          this.pieChartData = res.pie;
          this.barChartData = res.pie;
        },
        error: err => {
          console.error(JSON.stringify(err));
        }
      });
    }
}
