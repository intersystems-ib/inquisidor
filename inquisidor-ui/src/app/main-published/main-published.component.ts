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
import { Router } from '@angular/router';
import { MatCheckboxModule } from '@angular/material/checkbox';

@Component({
  selector: 'app-main-published',
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
    MatCheckboxModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './main-published.component.html',
  styleUrl: './main-published.component.scss'
})
export class MainPublishedComponent implements OnInit{

  formulario: FormGroup;
  contratanteSearch = new FormControl('');
  contratantes = new FormControl<string[]>([]);
  cpvSearch = new FormControl('');
  cpvs = new FormControl<{ Code: string; Description: string }[]>([]);
  titulo = new FormControl<string>("");
  busquedaVectorial = new FormControl<boolean>(false);
  
  resultados: { Name: string; NIF: string }[] = [];
  resultado: any = null;

  resultadosContratante: string[] = [];

  resultadosCPV: { Code: string; Description: string }[] = [];

  columnas: string[] = ['titulo', 'actualizado', 'contratante', 'fechalimite', 'importe', 'similitud'];
  datos: Array<any> = [];
  dataSource = new MatTableDataSource(this.datos);

  private searchContratanteSub: Subscription;
  private searchCPVSub: Subscription;

  cargando = true;

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  constructor(private irisService: IrisService,
    private fb: FormBuilder,
    private router: Router
  ) {
    this.formulario = this.fb.group({
      contratanteSearch: this.contratanteSearch,
      contratantes: this.contratantes,
      cpvSearch: this.cpvSearch,
      cpvs: this.cpvs,
      titulo: this.titulo,
      busquedaVectorial: this.busquedaVectorial
    });

    this.searchContratanteSub = this.contratanteSearch.valueChanges
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
        this.resultadosContratante = res;
      });

      this.searchCPVSub = this.cpvSearch.valueChanges
      .pipe(
        debounceTime(300),
        distinctUntilChanged(),
        switchMap(term => {
          if (!term || term.length < 3) return of([]);
          return from(this.irisService.getCPV(term)).pipe(
            catchError(() => this.router.navigate(['login']))
          );
        })
      )
      .subscribe(res => {
        this.resultadosCPV = res;
      });
  }

  ngOnInit() {
    this.cargando = false;
  }

  ngAfterViewInit() {
    this.dataSource.sort = this.sort;
  }

  filterList(filter: any) {
    this.cargando = true;
    this.irisService.getPublished(filter).subscribe({
      next: res => {  
        this.datos = res;
        this.dataSource = new MatTableDataSource(this.datos);
        this.dataSource.paginator = this.paginator;
        this.dataSource.sort = this.sort;
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

  addCPV(event: MatAutocompleteSelectedEvent) {
    const seleccionada = event.option.value as { Code: string; Description: string };

    const yaSeleccionadas = this.cpvs.value ?? [];
    const yaExiste = yaSeleccionadas.some(e => e.Code === seleccionada.Code);

    if (!yaExiste) {
      this.cpvs.setValue([...yaSeleccionadas, seleccionada]);
    }

    this.cpvSearch.setValue('');
  }

  removeCPV(code: string) {
    const actuales = this.cpvs.value ?? [];
    this.cpvs.setValue(actuales.filter(e => e.Code !== code));
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
        titulo: this.titulo.value,
        contratantes: this.contratantes.value,
        cpvs: this.cpvs.value,
        busquedaVectorial: this.busquedaVectorial.value
      };
      this.filterList({"filtros": this.resultado});
    }
  }

  ngOnDestroy(): void {
    this.searchContratanteSub.unsubscribe();
    this.searchCPVSub.unsubscribe();
  }
}
