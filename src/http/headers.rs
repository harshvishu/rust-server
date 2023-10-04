use std::collections::HashMap;

#[derive(Debug)]
pub struct Headers<'buf> {
    data: HashMap<&'buf str, String>,
}

impl<'buf> Headers<'buf> {
    pub fn get(&self, key: &str) -> Option<&String> {
        let value = self.data.get(key);
        value
    }
}

impl<'buf> From<&'buf str> for Headers<'buf> {
    fn from(s: &'buf str) -> Self {
        let mut data = HashMap::new();

        for sub_str in s.split("\r\n") {
            let mut key = sub_str;
            let mut val = "";

            if let Some(i) = sub_str.find(": ") {
                key = &sub_str[..i];
                val = &sub_str[i + 2..];
            }

            if !key.is_empty() && !val.is_empty() {
                data.insert(key, val.to_string());
            }
        }

        Headers { data }
    }
}
