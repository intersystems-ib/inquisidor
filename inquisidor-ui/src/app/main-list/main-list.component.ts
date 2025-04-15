import { Component, ViewChild, AfterViewInit, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatSort, MatSortModule } from '@angular/material/sort';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatToolbarModule } from '@angular/material/toolbar';
import { FormBuilder, FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatTableDataSource } from '@angular/material/table';
import { IrisService } from '../services/iris.service';
import { catchError, debounceTime, distinctUntilChanged, from, of, Subscription, switchMap } from 'rxjs';
import { MatAutocompleteModule, MatAutocompleteSelectedEvent } from '@angular/material/autocomplete';
import { MatChipListbox, MatChipOption, MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-main-list',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    CommonModule,
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    MatInputModule,
    MatFormFieldModule,
    MatAutocompleteModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatToolbarModule,
    MatChipsModule,
    MatChipListbox,
    MatChipOption,
    MatProgressSpinnerModule
  ],
  templateUrl: './main-list.component.html',
  styleUrl: './main-list.component.scss'
})
export class MainListComponent implements OnInit{

  formulario: FormGroup;
  empresaSearch = new FormControl('');
  empresas = new FormControl<{ Name: string; NIF: string }[]>([]);
  contratanteSearch = new FormControl('');
  contratantes = new FormControl<string[]>([]);
  titulo = new FormControl<string>("");
  
  resultados: { Name: string; NIF: string }[] = [];
  resultado: any = null;

  resultadosContratante: string[] = [];

  columnas: string[] = ['titulo', 'contratante', 'fecha', 'ganador', 'importe', 'similitud'];
  datos: Array<any> = [];
  dataSource = new MatTableDataSource(this.datos);

  private searchSub: Subscription;
  private searchContratanteSub: Subscription;

  cargando = true;

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  constructor(private irisService: IrisService,
    private fb: FormBuilder
  ) {
    this.formulario = this.fb.group({
      empresaSearch: this.empresaSearch,
      empresas: this.empresas,
      contratanteSearch: this.contratanteSearch,
      contratantes: this.contratantes,
      titulo: this.titulo
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

      this.searchContratanteSub = this.contratanteSearch.valueChanges
      .pipe(
        debounceTime(300),
        distinctUntilChanged(),
        switchMap(term => {
          if (!term || term.length < 3) return of([]);
          return from(this.irisService.getContractors(term)).pipe(
            catchError(() => of([]))
          );
        })
      )
      .subscribe(res => {
        this.resultadosContratante = res;
      });
  }

  ngOnInit() {
    this.cargando = false;
  }

  filterList(filter: any) {
    this.cargando = true;
    this.irisService.getTenders(filter).subscribe({
      next: res => {  
        this.datos = res;
        this.dataSource = new MatTableDataSource(this.datos);
        this.dataSource.paginator = this.paginator;
        this.dataSource.sort = this.sort;
      },
      error: err => {
        console.error(JSON.stringify(err));
      }, 
      complete: () =>  {
        this.cargando = false;
      }
    });
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
        empresas: this.empresas.value,
        titulo: this.titulo.value,
        contratantes: this.contratantes.value
      };
      this.filterList({"filtros": this.resultado});
    }
  }

  ngOnDestroy(): void {
    this.searchSub.unsubscribe();
  }
}
