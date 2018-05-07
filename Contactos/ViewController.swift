import UIKit
import Contacts
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    
    @IBOutlet weak var tabla: UITableView!
    var listaContactos = [Contactos]()
    var contactosStore = CNContactStore()
    @IBOutlet weak var editarOutlet: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        tabla.delegate = self
        tabla.dataSource = self
        
        contactosStore.requestAccess(for: .contacts) { (aceptar, error) in
            if aceptar {
                print("acceso permitido")
            }else{
                print("acceso denegado")
            }
            
            if let error = error {
                print("hubo un error en los contactos", error)
            }
        }
        fetchContactos()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return listaContactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tabla.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contacto = listaContactos[indexPath.row]
        cell.textLabel?.text = "\(contacto.nombre) \(contacto.apellido)"
        cell.detailTextLabel?.text = contacto.numero
        return cell
    }
    
    func fetchContactos(){
        let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: key)
        request.sortOrder = CNContactSortOrder.givenName
        try! contactosStore.enumerateContacts(with: request, usingBlock: { (contacto, point) in
            let nombre = contacto.givenName
            let apellido = contacto.familyName
            let numero = contacto.phoneNumbers.first?.value.stringValue ?? "sin numero"
            let contactosAgregar = Contactos(nombre: nombre, apellido: apellido, numero: numero)
            self.listaContactos.append(contactosAgregar)
        })
        DispatchQueue.main.async {
            self.tabla.reloadData()
        }
    }

    @IBAction func editar(_ sender: UIBarButtonItem) {
        tabla.isEditing = !tabla.isEditing
        if tabla.isEditing {
            editarOutlet.title = "Aceptar"
        }else{
            editarOutlet.title = "Editar"
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = listaContactos[sourceIndexPath.row]
        listaContactos.remove(at: sourceIndexPath.row)
        listaContactos.insert(item, at: sourceIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            listaContactos.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.tabla.reloadData()
            }
        }
    }
    
}











