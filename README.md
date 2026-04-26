# THANK vs ABM Macroeconomics Simulator

Aplicación en **R Shiny** para estudiar el mismo problema macroeconómico desde dos enfoques simultáneos:

- **THANK** (*Tractable Heterogeneous Agent New Keynesian*): estructura analítica compacta, útil para interpretación causal, política monetaria/fiscal y sensibilidad paramétrica.
- **ABM** (*Agent-Based Model*): sistema de agentes heterogéneos con interacciones no lineales, útil para contagio financiero, cambios de régimen y dinámicas emergentes.

La idea central del proyecto es que un macroeconomista no debería elegir “uno u otro”, sino **usar ambos en paralelo** y comparar resultados para distinguir:

1. Lo que es robusto a los supuestos (convergencia THANK–ABM).
2. Lo que depende críticamente de supuestos simplificadores (divergencia THANK–ABM).

---

## ¿Qué problema resuelve esta app?

En práctica aplicada, muchos modelos estructurales (incluyendo variantes THANK/HANK) pueden ser muy informativos, pero dependen de supuestos de tractabilidad: linealización local, expectativas disciplinadas, mercados financieros resumidos, etc.

Cuando el entorno entra en zonas no lineales (pánico, cascadas de defaults, cambios fuertes de reglas de comportamiento), esas simplificaciones pueden degradar la inferencia. Aquí es donde ABM sirve como **capa de estrés epistemológico**: prueba si el mensaje de política sobrevive cuando se sueltan supuestos fuertes.

Esta app permite ejecutar ambos motores con el mismo escenario y parámetros comparables, y entrega un panel de divergencia para diagnóstico rápido.

---

## Arquitectura del proyecto

```text
app/
├── app.R
├── ui.R
├── server.R
├── modules/
│   ├── thank_model.R
│   ├── abm_model.R
│   ├── comparison.R
│   └── scenario_loader.R
├── scenarios/
│   ├── fiscal_transfer.yaml
│   ├── financial_crisis.yaml
│   ├── supply_shock.yaml
│   └── liquidity_trap.yaml
├── data/
│   └── calibration_params.csv
└── www/
    └── styles.css
```

---

## Escenarios implementados y lectura teórica

### 1) Transferencia fiscal (esperable convergencia)
- **Intuición**: con fricciones moderadas y sin dislocación financiera extrema, THANK y ABM suelen coincidir en orden de magnitud del multiplicador.
- **Mensaje**: cuando los supuestos NK “aguantan”, THANK da una guía rápida y transparente.

### 2) Crisis financiera con contagio (divergencia)
- **Intuición**: defaults interconectados y credit crunch generan no linealidades de red.
- **THANK**: típicamente subestima la profundidad de la recesión si no modela explícitamente contagio.
- **ABM**: reproduce cascadas de fallas y efectos de segunda vuelta.

### 3) Shock de oferta con desigualdad (divergencia fuerte)
- **Intuición**: el shock pega distinto por decil, composición de canasta y restricciones de liquidez.
- **THANK**: al promediar, puede ocultar distribución del daño inflacionario.
- **ABM**: muestra ganadores/perdedores y trayectorias distributivas emergentes.

### 4) Trampa de liquidez / ZLB con pánico (falla de supuestos)
- **Intuición**: con tasa en cero y expectativas inestables, el comportamiento no es suave ni lineal.
- **THANK**: puede tener solución formal pero perder realismo conductual.
- **ABM**: permite cambios de heurísticas y colapso endógeno de demanda.

---

## Comparación THANK vs ABM: cuándo “gana” cada framework

### Fortalezas de THANK
- Interpretabilidad estructural alta.
- Rapidez para policy counterfactuals.
- Buen desempeño en entornos cercanos al estado estacionario y con no linealidades acotadas.

### Fortalezas de ABM
- Captura interacciones de red, heterogeneidad rica y cambios de régimen.
- Permite estudiar colas de riesgo, eventos raros y no linealidades profundas.
- Produce distribuciones (no solo trayectorias promedio).

### Regla práctica
- **THANK** como motor principal de síntesis y comunicación de política.
- **ABM** como motor de robustez y validación externa de supuestos.

No son sustitutos perfectos; son complementarios.

---

## ¿Por qué un macroeconomista debería trabajar “desde ambos lados”?

1. **Disciplina analítica + realismo emergente**: THANK ordena la intuición causal; ABM evita sobreconfianza en simplificaciones.
2. **Mejor gestión de riesgo de política**: si ambos convergen, mayor confianza; si divergen, se detectan zonas de fragilidad antes de recomendar intervención.
3. **Transparencia metodológica**: comparar modelos explicita qué resultados vienen de datos/mecanismos y cuáles de supuestos de cierre.
4. **Evitar falsos negativos de crisis**: solo con marco tractable se puede subestimar severidad de eventos sistémicos.

---

## ¿Por qué omitir ABM reduce robustez analítica de THANK?

Si se usa solo THANK, la validación queda “interna” al propio sistema de supuestos. Eso puede generar:

- **Riesgo de circularidad**: un modelo confirma lo que sus hipótesis ya imponían.
- **Subestimación de no linealidades**: contagio, quiebras encadenadas y pánico quedan amortiguados.
- **Pérdida de señal distributiva**: promedios agregados tapan heterogeneidad relevante para bienestar y política.
- **Exceso de confianza en respuestas locales**: buena aproximación cerca del equilibrio, débil fuera de él.

Por eso, incorporar ABM no “reemplaza” THANK; lo vuelve **más robusto** al exigirle pasar pruebas fuera del entorno para el que fue diseñado.

---

## Panel de comparación (núcleo pedagógico)

La app calcula un índice de divergencia (RMSE normalizado entre trayectoria THANK y mediana ABM) y lo resume con semáforo:

- **Verde**: convergencia (supuestos NK razonables para ese escenario).
- **Amarillo**: divergencia parcial (THANK subestima/sobrestima alguna variable).
- **Rojo**: divergencia severa (ABM más confiable para ese régimen).

Esto ayuda a transformar un debate metodológico abstracto en diagnóstico operativo.

---

## Ejecución local

```r
install.packages(c(
  "shiny", "bslib", "plotly", "igraph", "dplyr", "tidyr", "purrr", "yaml", "viridis"
))

shiny::runApp("app")
```

---

## Resumen ejecutivo

- THANK aporta claridad estructural y velocidad.
- ABM aporta realismo de interacción y validación en escenarios extremos.
- La combinación THANK+ABM mejora la calidad de inferencia y reduce riesgo de recomendaciones frágiles.
- En macro aplicada, **comparar ambos no es redundancia: es control de calidad científico**.


---

## Resumen ampliado: por qué el doble enfoque THANK + ABM importa

### La analogía más clara
Pensalo como un ingeniero estructural que diseña un puente con dos herramientas:

- **Cálculo analítico**: rápido, auditable, fácil de comunicar.
- **Simulación de elementos finitos (FEM)**: más costosa, pero captura efectos que las fórmulas simplificadas no ven.

Para casos rutinarios, la herramienta analítica puede alcanzar. Para escenarios extremos (viento lateral, sismo, fatiga estructural simultánea), la simulación deja de ser opcional. En macroeconomía sucede lo mismo: cuando hay riesgo de ruptura de régimen, usar un solo marco puede inducir errores severos de diagnóstico.

### La razón epistemológica de fondo
El punto no es solo técnico: es **qué tipo de certeza se comunica**.

- THANK puede dar números precisos y limpios para política.
- Pero esos números dependen de supuestos (expectativas racionales, linealización local, mercados financieros simplificados, estabilidad distributiva).
- Si esos supuestos fallan, la predicción no solo pierde precisión: puede equivocarse en dirección.

El ABM complementa porque no obliga esa suavidad estructural y ayuda a identificar cuándo “el número limpio” deja de ser confiable.

### Cuatro casos donde el doble análisis es fuertemente recomendable
1. **No linealidades potenciales**: crisis bancaria, corrida cambiaria, pánico.
2. **Distribución en transición**: shocks post-crisis, post-reformas o post-conflicto.
3. **Canal financiero central**: crédito, apalancamiento, spreads y contagio.
4. **Expectativas desancladas**: alta incertidumbre, episodios de pánico, ZLB persistente.

### La trampa simétrica: usar solo ABM también puede fallar
- Menor trazabilidad causal para comunicación de política.
- Mayor sensibilidad a supuestos de comportamiento/calibración.
- Menor aceptación en ciertos circuitos de evaluación formal.

Por eso este proyecto no plantea reemplazo, sino **complementariedad disciplinada**: THANK para estructura e interpretación; ABM para robustez externa y escenarios de cola.

### Regla operativa sugerida
| Situación | Solo THANK | Solo ABM | Doble enfoque |
|---|---|---|---|
| Ajuste de tasa rutinario | ✅ | ❌ | Opcional |
| Política fiscal moderada | ✅ | ❌ | Opcional |
| Crisis bancaria sistémica | ❌ | ❌ | ✅ |
| Reforma distributiva grande | ❌ | ❌ | ✅ |
| Shock externo severo (emergente) | ❌ | ❌ | ✅ |
| Trampa de liquidez / ZLB | ❌ | ❌ | ✅ |
| Stress test regulatorio | ❌ | ✅ | Opcional |

### Integración en bancos centrales (síntesis)
La práctica reciente en bancos centrales avanzados combina marcos estructurales (DSGE/HANK/THANK) con ABMs en capas:

1. **Forecast base y comunicación** con modelos estructurales.
2. **Stress testing financiero** con ABMs de red/contagio.
3. **Escenarios extremos/no lineales** con ABMs macro heterogéneos.

La lectura práctica para este repositorio es directa: no usar ABM como contraste puede dejar supuestos THANK sin validación externa y reducir robustez analítica en los episodios donde más importa acertar.

### Síntesis en una frase
> **THANK te dice la respuesta óptima dentro del modelo; ABM te dice si el modelo sobrevive al contacto con la realidad.**
