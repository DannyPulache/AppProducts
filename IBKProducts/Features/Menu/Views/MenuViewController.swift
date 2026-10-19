//
//  MenuViewController.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import UIKit

/// Pantalla donde el usuario puede cambiar el color del tab bar.
final class MenuViewController: UITableViewController {
    // La vista solo muestra lo que prepara el ViewModel.
    private let viewModel: MenuViewModel

    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(DeveloperMessages.coderInitializerUnavailable)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uso una tabla agrupada para que la opción se vea como un ajuste de iOS.
        title = AppStrings.Menu.title
        navigationItem.largeTitleDisplayMode = .always
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.themes.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        AppStrings.Menu.sectionTitle
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        // Cada fila muestra el nombre, una muestra del color y el check seleccionado.
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let theme = viewModel.themes[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = theme.displayName
        content.image = makeColorPreview(theme.color)
        cell.contentConfiguration = content
        cell.accessoryType = theme == viewModel.selectedTheme ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Quito el resaltado, guardo la elección y refresco los checks.
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectTheme(at: indexPath.row)
        tableView.reloadData()
    }

    /// Dibuja el circulito que sirve como muestra de cada color.
    private func makeColorPreview(_ color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24))
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 2, y: 2, width: 20, height: 20))
        }
    }
}
