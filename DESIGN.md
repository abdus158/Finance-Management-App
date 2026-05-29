---
name: Luminous Finance
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#bbcabf'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#86948a'
  outline-variant: '#3c4a42'
  surface-tint: '#4edea3'
  primary: '#4edea3'
  on-primary: '#003824'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#006c49'
  secondary: '#ffb3ad'
  on-secondary: '#68000a'
  secondary-container: '#a40217'
  on-secondary-container: '#ffaea8'
  tertiary: '#ffb95f'
  on-tertiary: '#472a00'
  tertiary-container: '#e29100'
  on-tertiary-container: '#523200'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#ffdad7'
  secondary-fixed-dim: '#ffb3ad'
  on-secondary-fixed: '#410004'
  on-secondary-fixed-variant: '#930013'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.02em
  numeric-data:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-margin-desktop: 40px
  container-margin-mobile: 20px
  gutter: 24px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

This design system is engineered for a high-fidelity financial experience that balances technical precision with a luxurious, immersive aesthetic. The brand personality is authoritative yet visionary—positioning the user as the "pilot" of their financial destiny. By leveraging a **Dark-Mode-First** approach, the interface reduces cognitive load while allowing critical data points to emerge through vibrant, glowing accents.

The visual style is a refined execution of **Glassmorphism**. It utilizes multi-layered depth, background saturation blurs, and "inner-glow" borders to simulate physical glass panes suspended in a deep digital void. The emotional response is one of security, clarity, and sophistication, moving away from dry institutional banking toward a sleek, modern command center.

## Colors

The palette is rooted in the "Abyss"—a combination of **True Black (#000000)** for deep backgrounds and **Midnight Blue/Charcoal** for container surfaces. This ensures maximum contrast for the functional color system.

- **Glowing Emerald (#10B981):** Represents growth, inflows, and positive status. It is the primary action color.
- **Neon Crimson (#EF4444):** Reserved for outflows, debt, and critical errors.
- **Soft Amber (#F59E0B):** Used sparingly for pending transactions and cautionary alerts.
- **Neutrals:** A range of cool grays and desaturated blues facilitate the glass effects, ensuring that text remains legible against varying levels of transparency.

## Typography

This design system utilizes **Inter** exclusively to maintain a systematic, utilitarian aesthetic. Typography is treated with a strict hierarchy to ensure financial data is never ambiguous.

For financial figures and currency displays, the `numeric-data` style must use **Tabular Figures** (tnum) to ensure that columns of numbers align perfectly, aiding in quick scanning of balance sheets. Headlines should use tighter letter spacing to maintain a premium, editorial feel, while labels utilize slight tracking increases for legibility at small sizes.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model within a 12-column system for desktop and a 4-column system for mobile. 

To emphasize the "premium" feel, this design system mandates **generous whitespace** (internal padding) within glassmorphic cards to prevent the UI from feeling cluttered. Elements are spaced using an 8px base grid. Structural "Auras" (soft radial gradients) are positioned behind primary containers to break the rigidity of the grid and provide a sense of atmospheric depth.

## Elevation & Depth

Depth is achieved through **Stacking and Refraction** rather than traditional drop shadows.

1.  **Base Level:** Solid #000000. No transparency.
2.  **Mid Level (Surface):** Glassmorphic containers with a `backdrop-filter: blur(20px)` and a background color of `rgba(30, 41, 59, 0.5)`.
3.  **High Level (Popovers/Modals):** Increased transparency and a 1px solid border using `glass_stroke`.
4.  **Active State:** Elements in an active or hovered state should emit a **Subtle Glowing Aura** using a low-spread box shadow tinted with the element's functional color (e.g., a green glow for cash-in cards).

## Shapes

The design system employs a **Rounded (0.5rem base)** shape language. This softens the technical nature of financial data, making the app feel more approachable. 

- **Cards & Modals:** Use `rounded-xl` (1.5rem) to create a distinct container feel.
- **Interactive Elements:** Buttons and input fields use the base `rounded` (0.5rem) setting.
- **Toggles:** Use the "Pill" shape for the outer track, while the inner handle should have a subtle 3D-embossed effect to appear tactile and "physical."

## Components

### Buttons
Primary action buttons use a solid gradient of the primary color with a 10% brightness inner-glow on the top edge. Secondary buttons use the glassmorphic style with a high-contrast white label.

### Glassmorphic Cards
The signature component. Each card features a 1px semi-transparent border (top and left edges should be slightly brighter than bottom and right to simulate light catch). Backgrounds must include a blur filter to ensure text remains readable over background auras.

### Physical Toggles
Unlike flat UI switches, these should have a slight inner shadow on the track and a subtle drop shadow on the handle to provide a tactile, skeuomorphic "click" sensation.

### Input Fields
Inputs are rendered as inset glass panes. When focused, the border transitions from the default glass stroke to a glowing Emerald or Crimson stroke depending on the context (e.g., an "Amount" field for a payment might glow Crimson).

### Lists
Transaction lists should be separated by thin, low-opacity dividers. "Growth" indicators (stock tickers, income) should be paired with thin-line upward trend icons in the primary color.
