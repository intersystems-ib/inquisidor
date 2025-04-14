import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ContratanteChartsComponent } from './contratante-charts.component';

describe('ContratanteChartsComponent', () => {
  let component: ContratanteChartsComponent;
  let fixture: ComponentFixture<ContratanteChartsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ContratanteChartsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ContratanteChartsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
