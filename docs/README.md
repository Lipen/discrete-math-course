# mdBook Website

## Quick Start

```bash
# Install mdBook
cargo install mdbook

# Build
mdbook build

# Development server
mdbook serve --open
```

## Content

All content in `src/` as Markdown:

- `src/welcome.md` - Homepage
- `src/SUMMARY.md` - Navigation structure
- `src/course/` - Course info
- `src/assessments/` - Homework, tests, exams
- `src/resources/` - Materials, help

## Editing

1. Edit Markdown files in `src/`
2. Update `src/SUMMARY.md` for navigation changes
3. Run `mdbook build` to regenerate
4. Output is in `dist/`

## Adding Pages

1. Create new `.md` file in appropriate directory
2. Add entry to `src/SUMMARY.md`:

    ```markdown
    - [New Page](path/to/new.md)
    ```

3. Rebuild

## Configuration

`book.toml` contains settings:

- Title, description, authors
- Build directory (`dist/`)
- Search settings
- GitHub integration

## Deployment

GitHub Actions automatically:

1. Builds mdBook on push to main
2. Deploys to GitHub Pages
3. Available at: <https://lipen.github.io/discrete-math-course/>

## Resources

- **mdBook Documentation**: <https://rust-lang.github.io/mdBook/>
- **Markdown Guide**: <https://www.markdownguide.org/>

## Structure

Markdown files are organized into 3 main sections:

1. **Course Information**
   - Overview, syllabus (4 modules), schedule, grading

2. **Assessments**
   - Homework, Tests, Colloquiums, Exam

3. **Resources**
   - Materials, support/help
