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
    MatChipOption
  ],
  templateUrl: './main-list.component.html',
  styleUrl: './main-list.component.scss'
})
export class MainListComponent implements OnInit{

  formulario: FormGroup;
  empresaSearch = new FormControl('');
  empresas = new FormControl<{ Name: string; NIF: string }[]>([]);
  titulo = new FormControl<string>("");
  
  resultados: { Name: string; NIF: string }[] = [];
  resultado: any = null;

  columnas: string[] = ['titulo', 'contratante', 'fecha', 'ganador', 'importe', 'similitud'];
  loading = false;
  datos: Array<any> = [];
  dataSource = new MatTableDataSource(this.datos);

   private searchSub: Subscription;

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  constructor(private irisService: IrisService,
    private fb: FormBuilder
  ) {
    this.formulario = this.fb.group({
      empresaSearch: this.empresaSearch,
      empresas: this.empresas,
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
  }

  ngOnInit() {
    this.loading = true;
  }

  filterList(filter: any) {
    this.irisService.getTenders(filter).subscribe({
      next: res => {  
        this.datos = res;
        this.dataSource = new MatTableDataSource(this.datos);
        this.loading = false;
        this.dataSource.paginator = this.paginator;
        this.dataSource.sort = this.sort;
      },
      error: err => {
        console.error(JSON.stringify(err));
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

  onSubmit() {
    if (this.formulario.valid) {
      this.resultado = {
        empresas: this.empresas.value,
        titulo: this.titulo.value
      };
      this.filterList({"filtros": this.resultado});
    }
  }

  ngOnDestroy(): void {
    this.searchSub.unsubscribe();
  }
}
