import Foundation
import RFC_2045
import RFC_2046
import Testing
import URLFormCoding
import WHATWG_HTML_FormData
import WHATWG_HTML_Forms

@testable import FormCoding

@Suite("README Verification")
struct ReadmeVerificationTests {

    @Test("Example from README: URL Form Encoding")
    func urlFormEncoding() throws {
        // `Form` is qualified locally: this file also imports the WHATWG
        // form-data model, whose top-level `Form` type would otherwise clash
        // with `URLFormCoding.Form`.
        typealias Form = URLFormCoding.Form

        // URL Form Encoding
        struct LoginForm: Codable {
            let username: String
            let password: String
        }

        let encoder = Form.Encoder()
        let form = LoginForm(username: "john", password: "secret")
        let formData = try encoder.encode(form)

        // Verify data was encoded
        #expect(formData.count > 0)

        // Verify it can be decoded back
        let decoder = Form.Decoder()
        let decoded = try decoder.decode(LoginForm.self, from: formData)
        #expect(decoded.username == "john")
        #expect(decoded.password == "secret")
    }

    @Test("Example from README: Multipart Form Data")
    func multipartFormData() throws {
        // `Form` here is the WHATWG HTML form-data model; qualified locally to
        // avoid the name clash with `URLFormCoding.Form` in this test file.
        typealias Form = WHATWG_HTML_Forms.Form

        let pngBytes: [UInt8] = [0x89, 0x50, 0x4E, 0x47]  // PNG signature

        // Build the form-data set: a text field plus a file field
        var form = Form.Data.Entry.List()
        form.append(name: "username", value: "alice")
        form.append(
            name: "avatar",
            file: Form.Data.File(
                name: "avatar.png",
                type: "image/png",
                body: pngBytes
            )
        )

        // Encode as multipart/form-data (RFC 7578)
        let multipart = try RFC_2046.Multipart(form)

        // Content-Type header (with a generated boundary) for the request
        let (contentType, boundary) = form.multipartContentType()

        // Verify the form-data set
        #expect(form.count == 2)
        #expect(form.first(named: "username")?.stringValue == "alice")
        #expect(form.first(named: "avatar")?.fileValue?.name == "avatar.png")
        #expect(form.first(named: "avatar")?.fileValue?.type == "image/png")
        #expect(form.first(named: "avatar")?.fileValue?.body == pngBytes)

        // Verify the encoded multipart body
        #expect(multipart.parts.count == 2)

        // Verify the derived Content-Type header
        #expect(!boundary.rawValue.isEmpty)
        #expect(contentType.headerValue.contains("multipart/form-data"))
        #expect(contentType.boundary == boundary.rawValue)
    }
}
