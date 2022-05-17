//
//  Requests.swift
//  LeanSdkDemo
//
//  Created by Fede Ruiz on 13/05/2022.
//

import Foundation

let API_HOST = "https://app.staging.withlean.com/"
let AUTH_KEY = "Basic ZUhwODhzVXhJYVhrSmJjaXptcFU6"

func postRequest(body: Any, path: String) -> NSMutableURLRequest {
    let url = NSURL(string: path)!
    let request = NSMutableURLRequest(url: url as URL)
    request.httpMethod = "POST"
    request.addValue(AUTH_KEY, forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    let jsonData = try? JSONSerialization.data(withJSONObject: body)
    
    request.httpBody = jsonData
    return request
}
